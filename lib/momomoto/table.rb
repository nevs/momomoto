
module Momomoto

  # this class implements to tables/views
  # it must not be used directly but you should inherit from this class
  # you can only write to a table if it has primary keys defined
  class Table < Base

    attr_accessor :limit, :order

    def initialize_class # :nodoc:
      self.class.class_eval do 
        unless class_variables.member?( '@@table_name' )
          table_name( construct_table_name( self.name ) )
        end
        unless class_variables.member?( '@@schema_name' )
          schema_name( construct_schema_name( self.name ) )
        end
        unless class_variables.member?( '@@columns' )
          columns( database.fetch_columns( table_name() ) )
        end

        unless class_variables.member?( '@@primary_keys' )
          primary_keys( database.fetch_primary_keys( table_name(), schema_name() ) )
        end

        # construct the Row class for the table
        const_set( :Row, Class.new )
        const_get(:Row).send(:define_method, :initialize) do | table, data |
          instance_variable_set(:@table, table) 
          instance_variable_set(:@data, data) 
        end
        const_get(:Row).send(:define_method, :new_record?) do 
          instance_variable_get(:@new_record)
        end

        columns().each_with_index do | ( field_name, data_type ), index |
          # mark primary key rows
          if primary_keys.member?( field_name )
            data_type.send(:instance_variable_set, :@primary_key, true)
          end
          # define getter and setter for row class
          const_get(:Row).send(:define_method, field_name) do
            data_type.filter_get( instance_variable_get(:@data)[index] )
          end
          const_get(:Row).send(:define_method, (field_name.to_s + '=').to_sym ) do | value |
            instance_variable_get(:@data)[index] = data_type.filter_set( value )
          end
        end

        # define write method for Rows if we found primary keys
        if primary_keys.length > 0
          const_get(:Row).send( :define_method, :write ) do
            instance_variable_get(:@table).write( self )
          end
        else
          undef_method(:write)
          undef_method(:create)
        end

      end

    end

    # guesses the table name of the table this class works on
    def self.construct_table_name( classname ) # :nodoc:
      classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
    end

    # set the table_name of the table this class operates on
    def self.table_name=( table_name )
      send(:class_variable_set, :@@table_name, table_name)
    end

    # get the table_name of the table this class operates on
    def self.table_name( table_name = nil )
      return self.table_name=( table_name ) if table_name
      begin
        send(:class_variable_get, :@@table_name)
      rescue NameError
        construct_table_name( self.name )
      end
    end

    # set the primary key fields of the table
    def self.primary_keys=( keys ) # :nodoc:
      send(:class_variable_set, :@@primary_keys, keys)
    end

    # get the primary key fields of the table
    def self.primary_keys( keys = nil )
      return self.primary_keys=( keys ) if keys
      begin
        send(:class_variable_get, :@@primary_keys)
      rescue
        self.primary_keys=( database.fetch_primary_keys( table_name(), schema_name()) )
      end
    end

    # class method for selecting
    def self.select( conditions = {}, options = {} )
      klass = self.new
      klass.select( conditions, options )
    end

    ## Searches for records and returns the number of records found
    def select( conditions = {}, options = {} )
      sql = "SELECT " + self.class.columns.keys.map{ | field | '"' + field.to_s + '"' }.join( "," ) + " FROM "
      sql += self.class.schema_name + '.' if self.class.schema_name
      sql += self.class.table_name
      sql += compile_where( conditions )
      sql += " LIMIT #{options[:limit]}" if options[:limit]
      sql += " ORDER BY #{options[:order]}" if options[:order]
      @data = []
      self.class.database.execute( sql ).each do | row |
        @data << self.class.const_get(:Row).new( self, row )
      end
      self
    end

    def create( fields = {} )
      new_row = self.class.const_get(:Row).new( self, [] )
      new_row.send(:instance_variable_set, :@new_record, true)
      fields.each do | key, value |
        new_row.send( key, value )
      end
      new_row
    end

    ## Tries to find a specific record and creates a new one if it does not find it
    #  raises an exception if multiple records are found
    def select_or_create( conditions, options )
      
    end

    # write row back to database
    def write( row ) # :nodoc:
      raise CriticalError unless row.class == self.class.const_get(:Row)
      if row.new_record?
        insert( row )
      else
        update( row )
      end
    end

    # create an insert statement for a row
    def insert( row ) # :nodoc:
      fields, values = [], []
      self.class.columns.each do | field_name, datatype |
        # check for set primary key fields or fetch respective default values
        if datatype.primary_key? 
          if row.send( field_name).nil? && datatype.default
            row.send( "#{field_name}=", self.class.database.execute("SELECT #{datatype.default};")[0][0] )
          end
          if row.send( field_name ).nil?
            raise Momomoto::CriticalError, "Primary key fields need to be set or must have a default"
          end
        end
        next if row.send( field_name ).nil?
        fields << field_name
        values << datatype.escape( row.send( field_name ))
      end
      raise CriticalError, "insert with all fields nil" if fields.empty?
      sql = "INSERT INTO #{self.class.table_name}(#{fields.join(', ')}) VALUES (#{values.join(', ')});"
      self.class.database.execute( sql )
    end

    # create an update statement for a row
    def update( row ) # :nodoc:
      setter, conditions = [], {}
      self.class.columns.each do | field_name, data_type |
        setter << "#{field_name} = #{data_type.escape(row.send( field_name ))}"
      end
      self.class.primary_keys.each do | field_name |
        raise "Primary key fields must not be empty!" if not row.send( field_name )
        conditions[field_name] = row.send( field_name )
      end
      sql = "UPDATE #{self.class.table_name} SET #{setter.join(', ')} #{compile_where(conditions)};"
      self.class.database.execute( sql )
    end

  end

end

