
module Momomoto

  # this class implements access to tables/views
  # it must not be used directly but you should inherit from this class
  class Table < Base

    class << self

      # set the default order for selects
      def default_order=( order )
        @default_order = order
      end

      # get the default order for selects
      def default_order( order = nil )
        return self.default_order=( order ) if order
        @default_order
      end

      # set the columns of the table this class operates on
      def columns=( columns )
        # we store the order separate because it's quite important 
        # that it's constant otherwise get_column and set_column 
        # on the row class might stop working 
        @column_order = columns.keys
        @columns = columns
      end

      # get the columns of the table this class operates on
      def columns( columns = nil )
        return self.columns=( columns ) if columns
        if not instance_variable_defined?( :@columns )
          initialize_table
        end
        @columns
      end

      # get the columns of this table
      def column_order #:nodoc:
        @column_order
      end

      def initialize_table # :nodoc:

        @table_name ||= construct_table_name( self.name )
        @schema_name ||= construct_schema_name( self.name )

        @columns ||= database.fetch_table_columns( table_name(), schema_name() ) 
        raise CriticalError, "No fields in table #{table_name}" if columns.keys.empty?

        @primary_keys ||= database.fetch_primary_keys( table_name(), schema_name() )
        @column_order = @columns.keys
        @default_order ||= nil

        @logical_operator ||= "AND"

        const_set( :Row, Class.new( Momomoto::Row ) ) if not const_defined?( :Row )
        initialize_row( const_get( :Row ), self )

        # mark class as initialized
        self.initialized = true

      end

      # guesses the table name of the table this class works on
      def construct_table_name( classname ) # :nodoc:
        classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
      end

      # set the table_name of the table this class operates on
      def table_name=( table_name )
        @table_name = table_name
      end

      # get the table_name of the table this class operates on
      def table_name( table_name = nil )
        return self.table_name=( table_name ) if table_name
        @table_name
      end

      # get the full name of a table including schema if set
      def full_name
        "#{ schema_name ? schema_name + '.' : ''}#{table_name}"
      end

      # set the primary key fields of the table
      def primary_keys=( keys ) # :nodoc:
        @primary_keys = keys
      end

      # get the primary key fields of the table
      def primary_keys( keys = nil )
        return self.primary_keys=( keys ) if keys
        initialize_table unless initialized
        @primary_keys
      end

      # compile the select clause
      def compile_select( conditions, options ) # :nodoc:
        if options[:columns] 
          cols = {}
          options[:columns].each do | name | cols[name] = columns[name] end
        else
          cols = columns
        end
        sql = "SELECT " + cols.keys.map{ | field | '"' + field.to_s + '"' }.join( "," ) + " FROM "
        sql += full_name
        sql += compile_where( conditions )
        sql += compile_order( options[:order] ) if options[:order] || default_order
        sql += compile_limit( options[:limit] ) if options[:limit]
        sql += compile_offset( options[:offset] ) if options[:offset]
        sql
      end

      # Searches for records and returns an array containing the records
      def select( conditions = {}, options = {} )
        initialize_table unless initialized
        if options[:columns]
          row_class = Class.new( Momomoto::Row )
          cols = {}
          columns.each do | key, value |
            cols[key] = value if options[:columns].member?( key )
          end
          define_row_accessors( row_class, self, cols )
        else
          row_class = const_get(:Row)
        end
        sql = compile_select( conditions, options )
        data = []
        database.execute( sql ).each do | row |
          data << row_class.new( row )
        end
        data
      end

      # Searches for records and returns an array containing the records
      def select_outer_join( conditions = {}, options = {} )
        initialize_table unless initialized
        join_table = options[:join]
        fields = columns.keys.map{|field| full_name+'."'+field.to_s+'"'}
        fields += join_table.columns.keys.map{|field| join_table.full_name+'."'+field.to_s+'"'}

        sql = "SELECT " + fields.join( "," ) + " FROM "
        sql += full_name
        sql += " LEFT OUTER JOIN " + join_table.full_name + " USING(#{join_columns(join_table).join(',')})"
        sql += compile_where( conditions )
        sql += compile_order( options[:order] ) if options[:order]
        sql += compile_limit( options[:limit] ) if options[:limit]
        sql += compile_offset( options[:offset] ) if options[:offset]
        data = {}
        database.execute( sql ).each do | row |
          new_row = row[0, columns.keys.length]
          data[new_row] ||= []
          join_row = row[columns.keys.length,join_table.columns.keys.length]
          data[new_row] << join_table.const_get(:Row).new( join_row ) if join_row.nitems > 0
        end
        result = []
        data.each do | new_row, join_row |
          new_row = const_get(:Row).new( new_row )
          new_row.instance_variable_set(:@join, join_row)
          new_row.send( :instance_eval ) { class << self; self; end }.send(:define_method, join_table.table_name ) do join_row end
          result << new_row
        end
        result
      end

      # returns the columns to be used for joining
      def join_columns( join_table ) # :nodoc:
        join_table.primary_keys.select{|f| columns.key?(f)}
      end

      # constructor for a record in this table accepts a hash with presets for the fields of the record
      def new( fields = {} )
        initialize_table unless initialized
        new_row = const_get(:Row).new( [] )
        new_row.new_record = true
        # set default values
        columns.each do | key, value |
          next if primary_keys.member?( key )
          if value.default
            if value.default.match( /^\d+$/ )
              new_row[ key ] = value.default
            elsif value.default == "true"
              new_row[ key ] = true
            elsif value.default == "false"
              new_row[ key ] = false
            elsif m = value.default.match( /^'([^']+)'::(text|interval|timestamp with time(out)? zone|time with(out)? time zone)$/ )
              new_row[ key ] = m[1]
            end
          end
        end
        fields.each do | key, value |
          new_row[ key ] = value
        end
        new_row
      end

      # Tries to find a specific record and creates a new one if it does not find it.
      # Raises an exception if multiple records are found.
      # You can pass a block which has to deliver the respective values for the
      # primary key fields
      def select_or_new( conditions = {}, options = {} )
        begin
          if block_given?
            conditions = conditions.dup
            primary_keys.each do | field |
              conditions[ field ] = yield( field ) if not conditions[ field ]
              raise ConversionError if not conditions[ field ]
            end
          end
          rows = select( conditions, options )
        rescue ConversionError
        end
        if rows && rows.length > 1
          raise Too_many_records, "Multiple values found in select_or_new for #{self}:#{conditions.inspect}"
        elsif rows && rows.length == 1
          rows.first
        else
          new( options[:copy_values] != false ? conditions : {} )
        end
      end

      # Select a single row from the database, raises an exception if more or zero
      # rows are found
      def select_single( conditions = {}, options = {} )
        data = select( conditions, options )
        case data.length
          when 0 then raise Nothing_found, "nothing found in #{table_name}"
          when 1 then return data[0]
          else raise Too_many_records, "too many records found in #{table_name}"
        end
      end

      # write row back to database
      def write( row ) # :nodoc:
        raise CriticalError unless row.class == const_get(:Row)
        if row.new_record?
          insert( row )
        else
          return false unless row.dirty?
          update( row )
        end
        row.clean_dirty
        true
      end

      # create an insert statement for a row
      def insert( row ) # :nodoc:
        fields, values = [], []
        columns.each do | field_name, datatype |
          # check for set primary key fields or fetch respective default values
          if primary_keys.member?( field_name ) && row.send( field_name ) == nil
            if datatype.default
              row.send( "#{field_name}=", database.execute("SELECT #{datatype.default};")[0][0] )
            end
            if row.send( field_name ) == nil
              raise Error, "Primary key fields(#{field_name}) need to be set or must have a default"
            end
          end
          next if row.send( field_name ).nil?
          fields << field_name
          values << datatype.escape( row.get_column( field_name ))
        end
        raise Error, "insert with all fields nil" if fields.empty?
        sql = "INSERT INTO " + full_name + '(' + fields.join(',') + ') VALUES (' + values.join(',') + ');'
        row.new_record = false
        database.execute( sql )
      end

      # create an update statement for a row
      def update( row ) # :nodoc:
        raise CriticalError, 'Updating is only allowed for tables with primary keys' if primary_keys.empty?
        setter, conditions = [], {}
        columns.each do | field_name, data_type |
          next if not row.dirty.member?( field_name )
          setter << field_name.to_s + ' = ' + data_type.escape(row.get_column(field_name))
        end
        primary_keys.each do | field_name |
          raise Error, "Primary key fields must not be empty!" if not row.send( field_name )
          conditions[field_name] = row.send( field_name )
        end
        sql = 'UPDATE ' + full_name + ' SET ' + setter.join(',') + compile_where( conditions ) + ';'
        database.execute( sql )
      end

      def delete( row ) # :nodoc:
        raise CriticalError, 'Deleting is only allowed for tables with primary keys' if primary_keys.empty?
        raise Error, "this is a new record" if row.new_record?
        conditions = {}
        primary_keys.each do | field_name |
          raise Error, "Primary key fields must not be empty!" if not row.send( field_name )
          conditions[field_name] = row.send( field_name )
        end
        sql = "DELETE FROM #{table_name} #{compile_where(conditions)};"
        row.new_record = true
        database.execute( sql )
      end

    end

  end

end

