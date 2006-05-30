
module Momomoto

  # this class implements to tables/views
  # it must not be used directly but you should inherit from this class
  # you can only write to a table if it has primary keys defined
  class Table < Base
  
    # set the columns of the table this class operates on
    def self.columns=( columns )
      class_variable_set( :@@columns, columns)
    end

    # get the columns of the table this class operates on
    def self.columns( columns = nil )
      return self.columns=( columns ) if columns
      begin
        class_variable_get( :@@columns )
      rescue NameError
        initialize_class
        class_variable_get( :@@columns )
      end
    end

    def self.initialize_class # :nodoc:
  
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

      const_set( :Row, Class.new( Momomoto::Row ) ) if not const_defined?( :Row )
      initialize_row( const_get( :Row ), self )

      # mark class as initialized
      class_variable_set( :@@initialized, true)

    end

    # construct the Row class for the table
    def self.initialize_row( row, table ) # :nodoc:

      if not row.ancestors.include?( Momomoto::Row )
        raise CriticalError, "Row is not inherited from Momomoto::Row" 
      end

      row.instance_eval do class_variable_set( :@@table, table ) end

      columns.each_with_index do | ( field_name, data_type ), index |
        # define getter and setter for row class
        row.instance_eval do
          define_method( field_name ) do
            data_type.filter_get( instance_variable_get(:@data)[index] )
          end
          define_method( "#{field_name}=" ) do | value |
            if not new_record? and table.primary_keys.member?( field_name )
              raise Error, 'setting primary keys is only allowed for new records' 
            end
            instance_variable_get(:@data)[index] = data_type.filter_set( value )
          end
        end
      end

    end

    # guesses the table name of the table this class works on
    def self.construct_table_name( classname ) # :nodoc:
      classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
    end

    # set the table_name of the table this class operates on
    def self.table_name=( table_name )
      class_variable_set( :@@table_name, table_name )
    end

    # get the table_name of the table this class operates on
    def self.table_name( table_name = nil )
      return self.table_name=( table_name ) if table_name
      begin
        class_variable_get( :@@table_name )
      rescue NameError
        construct_table_name( self.name )
      end
    end

    # get the full name of a table including schema if set
    def self.full_name
      "#{ schema_name ? schema_name + '.' : ''}#{table_name}"
    end

    # set the primary key fields of the table
    def self.primary_keys=( keys ) # :nodoc:
      class_variable_set( :@@primary_keys, keys )
    end

    # get the primary key fields of the table
    def self.primary_keys( keys = nil )
      return self.primary_keys=( keys ) if keys
      begin
        class_variable_get( :@@primary_keys )
      rescue
        self.primary_keys=( database.fetch_primary_keys( table_name(), schema_name()) )
      end
    end

    ## Searches for records and returns the number of records found
    def self.select( conditions = {}, options = {} )
      initialize_class unless class_variables.member?('@@initialized')
      sql = "SELECT " + columns.keys.map{ | field | '"' + field.to_s + '"' }.join( "," ) + " FROM "
      sql += full_name
      sql += compile_where( conditions )
      sql += compile_order( options[:order] ) if options[:order]
      sql += " LIMIT #{Integer(options[:limit])}" if options[:limit]
      data = []
      database.execute( sql ).each do | row |
        data << const_get(:Row).new( row )
      end
      data
    end

    # compiles the sql statement defining the table order
    def self.compile_order( order ) # :nodoc:
      order = [ order ] if not order.kind_of?( Array )
      order = order.map do | field |
        field = field.to_s
        raise Error if not columns.keys.member?( field.to_sym )
        "lower(#{field})"
      end
      " ORDER BY #{order.join(',')}"
    end

    def self.new( fields = {} )
      initialize_class unless class_variables.member?('@@initialized')
      new_row = const_get(:Row).new( [] )
      new_row.instance_variable_set( :@new_record, true )
      fields.each do | key, value |
        new_row.send( "#{key}=", value )
      end
      new_row
    end

    ## Tries to find a specific record and creates a new one if it does not find it
    #  raises an exception if multiple records are found
    #  You can pass a block which has to deliver the respective values for the 
    #  primary key fields
    def self.select_or_new( conditions = {}, options = {} )
      if block_given?
        primary_keys.each do | field | 
          conditions[ field ] = yield( field ) if not conditions[ field ]
        end
      end
      rows = select( conditions, options )  
      raise Error, 'Multiple values found in select_or_create' if rows.length > 1
      rows.empty? ? new( conditions ) : rows.first
    end

    # write row back to database
    def self.write( row ) # :nodoc:
      raise CriticalError unless row.class == const_get(:Row)
      if row.new_record?
        insert( row )
      else
        update( row )
      end
    end

    # create an insert statement for a row
    def self.insert( row ) # :nodoc:
      fields, values = [], []
      columns.each do | field_name, datatype |
        # check for set primary key fields or fetch respective default values
        if primary_keys.member?( field_name ) && row.send( field_name ) == nil
          if datatype.default
            row.send( "#{field_name}=", database.execute("SELECT #{datatype.default};")[0][0] )
          end
          if row.send( field_name ) == nil
            raise Error, "Primary key fields need to be set or must have a default"
          end
        end
        next if row.send( field_name ).nil?
        fields << field_name
        values << datatype.escape( row.send( field_name ))
      end
      raise Error, "insert with all fields nil" if fields.empty?
      sql = "INSERT INTO #{table_name}(#{fields.join(', ')}) VALUES (#{values.join(', ')});"
      row.instance_variable_set( :@new_record, false )
      database.execute( sql )
    end

    # create an update statement for a row
    def self.update( row ) # :nodoc:
      raise CriticalError, 'Updating is only allowed for tables with primary keys' if primary_keys.empty?
      setter, conditions = [], {}
      columns.each do | field_name, data_type |
        setter << "#{field_name} = #{data_type.escape(row.send( field_name ))}"
      end
      primary_keys.each do | field_name |
        raise Error, "Primary key fields must not be empty!" if not row.send( field_name )
        conditions[field_name] = row.send( field_name )
      end
      sql = "UPDATE #{table_name} SET #{setter.join(', ')} #{compile_where(conditions)};"
      database.execute( sql )
    end

    def self.delete( row ) # :nodoc:
      raise CriticalError, 'Deleting is only allowed for tables with primary keys' if primary_keys.empty?
      raise Error, "this is a new record" if row.new_record?
      conditions = {}
      primary_keys.each do | field_name |
        raise Error, "Primary key fields must not be empty!" if not row.send( field_name )
        conditions[field_name] = row.send( field_name )
      end
      sql = "DELETE FROM #{table_name} #{compile_where(conditions)};"
      row.instance_variable_set( :@new_record, true )
      database.execute( sql )
    end

  end

end

