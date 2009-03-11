
module Momomoto

  # This class implements access to tables/views.
  # It must not be used directly but you should inherit from this class.
  class Table < Base

    # controls the default order for selects
    momomoto_attribute :default_order

    # the columns of this table
    momomoto_attribute :columns

    # the table name of this table
    momomoto_attribute :table_name

    # array containing the primary key fields of the table
    momomoto_attribute :primary_keys

    # the table type of this table
    momomoto_attribute :table_type

    class << self

      # get the full name of table including, if set, schema
      def full_name
        "#{ schema_name ? schema_name + '.' : ''}#{table_name}"
      end

      # is this a base table
      def base_table?
        table_type == "BASE TABLE"
      end

      # is this a view
      def view?
        table_type == "VIEW"
      end

      # Searches for records and returns an Array containing the records.
      # There are a bunch of different use cases as this method is the primary way
      # to access all rows in the database.
      #
      # Selecting rows based on expression:
      #   #selects the feeds that match both the given url and author fields
      #   Posts.select(:feed_url => "https://www.c3d2.de/news-atom.xml",:author => "fnord")
      #
      # Using order statements:
      #   See Order#asc, Order#desc and Order#lower
      #
      #   #Selects conferences depending on start_date, starting with the oldest date.
      #   #If two conferences start at the same date(day) use the second order parameter
      #   #start_time.
      #   Conference.select({},{:order => Momomoto.asc([:start_date,:start_time])} )
      #
      # Using limit statement:
      #   See Base#compile_limit
      #
      #   #selects five feeds
      #   five_feeds = Feeds.select( {},{:limit => 5} )
      #
      # Using offset statement:
      #   See Base#compile_offset
      #
      #   #selects five feeds ommitting the first 23 rows
      #   five_feeds = Feeds.select( {}, {:offset => 23, :limit => 5} )
      #
      # Using logical operators:
      #   See Datatype::Base#operator_sign for basic comparison operators
      #   See Base#logical_operator for the supported logical operators
      #
      #   #selects the posts where the content field case-insensitevely matches
      #   #"surveillance".
      #   Posts.select( :content => {:ilike => 'surveillance'} )
      #
      #   #selects all conferences with a start_date before the current time.
      #   Conferences.select( :start_date => {:le => Time.now} )
      # 
      #   feed1 = "https://www.c3d2.de/news-atom.xml"
      #   feed2 = "http://www.c3d2.de/news-atom.xml"
      #   #selects the feeds with a field url that matches either feed1 or feed2
      #   Feeds.select( :OR=>{:url => [feed1,feed2]} )
      #
      #   
      # Selecting only given columns:
      #   See Base#initialize_row for the implementation
      #
      #   #selects title and content for every row found in table Posts.
      #   posts = Posts.select({},{:columns => [:title,:content]} )
      #
      #   The returned rows are special. They do not contain getter and setter
      #   for the rest of the columns of the row. Only the specified columns
      #   and all the primary keys of the table have proper accessor methods.
      #
      #   However, you can still change the rows and write them back to database:
      #   posts.first.title = "new title"
      #   posts.first.write
      def select( conditions = {}, options = {} )
        initialize unless initialized
        row_class = build_row_class( options )
        sql = compile_select( conditions, options )
        data = []
        database.execute( sql ).each do | row |
          data << row_class.new( row )
        end
        data
      end

      # experimental
      #
      # Searches for records and returns an array containing the records
      def select_outer_join( conditions = {}, options = {} )
        initialize unless initialized
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

      # constructor for a record in this table accepts a hash with presets for the fields of the record
      def new( fields = {} )
        initialize unless initialized
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
            elsif m = value.default.match( /^'([^']+)'::(text|interval|time(stamp)? with(out)? time zone)$/ )
              new_row[ key ] = m[1]
            end
          end
        end
        fields.each do | key, value |
          new_row[ key ] = value
        end
        new_row
      end

      # Tries to select the specified record or creates a new one if it does not find it.
      # Raises an exception if multiple records are found.
      # You can pass a block which has to deliver the respective values for the
      # primary key fields.
      #
      #   # selects the feed row matching the specified URL or creates a new
      #   # row based on the given URL.
      #   Feeds.select_or_new( :url => "https://www.c3d2.de/news-atom.xml" )
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

      # Select a single row from the database
      # raises Momomoto::Nothing_found if no row matched.
      # raises Momomoto::Too_many_records if more than one record was found.
      def select_single( conditions = {}, options = {} )
        data = select( conditions, options )
        case data.length
          when 0 then raise Nothing_found, "nothing found in #{full_name}"
          when 1 then return data[0]
          else raise Too_many_records, "too many records found in #{full_name}"
        end
      end

      # Writes row back to database.
      # This method is called by Momomoto::Row#write
      def write( row ) # :nodoc:
        if row.new_record?
          insert( row )
        else
          return false unless row.dirty?
          update( row )
        end
        row.clean_dirty
        true
      end

      # Creates an insert statement for a row.
      # Do not use it directly but use row.write or Table.write(row) instead.
      def insert( row )
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

      # Creates an update statement for a row.
      # Do not call update directly but use row.write or Table.write(row) instead.
      #
      # Get the value of row.new_record? before writing to database to find out
      # if you are updating a row that already exists in the database.
      #
      #   feed = Feeds.select_single( :url => "http://www.c3d2.de/news-atom.xml" )
      #   feed.new_record? => false
      #   feed[:url] = "https://www.c3d2.de/news-atom.xml"
      #   feed.new_record? => false
      #
      #   feed = Feeds.select_or_new( :url => "http://astroblog.spaceboyz.net/atom.rb" )
      #   feed.new_record? => true
      #   feed.write => true
      #   feed.new_record? => false
      def update( row )
        raise CriticalError, 'Updating is only allowed for tables with primary keys' if primary_keys.empty?
        setter, conditions = [], {}
        row.class.columns.each do | field_name, data_type |
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

      # delete _row_ from table
      def delete( row )
        raise CriticalError, 'Deleting is only allowed for tables with primary keys' if primary_keys.empty?
        raise Error, "this is a new record" if row.new_record?
        conditions = {}
        primary_keys.each do | field_name |
          raise Error, "Primary key fields must not be empty!" if not row.send( field_name )
          conditions[field_name] = row.send( field_name )
        end
        sql = "DELETE FROM #{full_name} #{compile_where(conditions)};"
        row.new_record = true
        database.execute( sql )
      end

      protected

      # guesses the table name of the table this class works on
      def construct_table_name( classname )
        classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
      end

      # get namespace of current class
      def namespace
        if self.name.split('::').length > 1
          const_get( self.name.split('::')[0..-2].join('::') )
        else
          Object
        end
      end

      # initializes a table class
      def initialize
        return if initialized
        super

        @table_name ||= construct_table_name( self.name )

        @columns ||= database.fetch_table_columns( table_name(), schema_name() )
        @table_type ||= database.get_table_type( table_name, schema_name )
        @primary_keys ||= database.fetch_primary_keys( table_name(), schema_name() )
        @column_order = @columns.keys
        @default_order ||= nil

        const_set( :Row, Class.new( Momomoto::Row ) ) if not const_defined?( :Row )
        initialize_row( const_get( :Row ), self )
        @row_cache = {}

        # define helper methods for foreign key relations
        if base_table?
          
          # find all columns that reference other tables and add helper methods for those keys
          Information_schema::Table_constraints.select({:table_name=>table_name,:table_schema=>schema_name,:constraint_type=>'FOREIGN KEY'}).each do | fk |
            referenced_columns = Information_schema::Constraint_column_usage.select({:constraint_name=>fk.constraint_name,:constraint_schema=>fk.constraint_schema})
            raise CriticalError, "Foreign key constraint without referenced columns" if referenced_columns.length == 0
            ref_table = referenced_columns[0].table_name
            # check if there is already a method by that name defined on Row
            if !const_get( :Row ).instance_methods.member?( ref_table )
              begin
                klass = namespace.const_get( ref_table.capitalize )
              rescue
                # if there is no such class yet we create one in the appropriate namespace
                klass = Class.new( Momomoto::Table )
                klass.table_name = ref_table
                klass.schema_name = referenced_columns[0].table_schema
                namespace.const_set( ref_table.capitalize, klass )
              end
              ref_columns = referenced_columns.map(&:column_name).map(&:to_sym)
              fk_helper_single( ref_table, klass, ref_columns )
            end
          end

          # find other tables that reference this table and add helper methods
          if primary_keys.length == 1
            Information_schema::Constraint_column_usage.select({:table_name=>table_name,:table_schema=>schema_name,:column_name=>primary_keys[0]}).each do | fk |
              constraint = Information_schema::Table_constraints.select({:constraint_name=>fk.constraint_name,:constraint_schema=>fk.constraint_schema,:constraint_type=>'FOREIGN KEY'})[0]
              # check if there is already a method by that name defined on Row
              if constraint && !const_get( :Row ).instance_methods.member?( constraint.table_name )

                begin
                  klass = namespace.const_get( constraint.table_name.capitalize )
                rescue
                  # if there is no such class yet we create one in the appropriate namespace
                  klass = Class.new( Momomoto::Table )
                  klass.table_name = constraint.table_name
                  klass.schema_name = constraint.table_schema
                  namespace.const_set( constraint.table_name.capitalize, klass )
                end
                fk_helper_multiple( constraint.table_name, klass, primary_keys )
              end
            end
          end

        end

      end

      # Define a helper method +method_name+ for +table_class+ 
      def fk_helper_single( method_name, table_class, ref_columns )
        var_name = "@#{method_name}".to_sym
        const_set(:Methods, Module.new) if not const_defined?(:Methods)
        const_get(:Methods).send(:define_method, method_name) do
          return instance_variable_get( var_name ) if instance_variable_defined?( var_name )
          conditions = {}
          ref_columns.each do | col | conditions[col] = get_column( col ) end
          begin
            value = table_class.select_single( conditions )
          rescue Momomoto::Nothing_found
            value = nil
          end
          instance_variable_set( var_name, value )
        end
      end

      # Define a helper method +method_name+ for +table_class+ 
      def fk_helper_multiple( method_name, table_class, ref_columns )
        var_name = "@#{method_name}".to_sym
        const_set(:Methods, Module.new) if not const_defined?(:Methods)
        const_get(:Methods).send(:define_method, method_name) do | *args |
          conditions = args[0] || {}
          options = args[1] || {}
          ref_columns.each do | col | conditions[col] = get_column( col ) end
          value = table_class.select( conditions, options )
          instance_variable_set( var_name, value )
        end
      end

      # Builds the row class for this table when executing #select.
      # In the default Row class proper setter and getter are available
      # for all columns. However, if you only want to select a few
      # columns as in
      #
      #   Feeds.select( {}, {:columns => [:url,:last_changed]} )
      #
      # #build_row_class does not return the default Row class for this table
      # but invokes Base#initialize_row to create a new class without
      # the setter and getter for the unused columns.
      # For better performance the newly created class is cached in +@row_cache+.
      def build_row_class( options )
        if options[:columns]
          options[:columns] += primary_keys
          options[:columns].uniq!
          if not @row_cache[options[:columns]]
            row_class = Class.new( Momomoto::Row )
            cols = {}
            columns.each do | key, value |
              cols[key] = value if options[:columns].member?( key )
            end
            initialize_row( row_class, self, cols )
            @row_cache[options[:columns]] = row_class
          end
          return @row_cache[options[:columns]]
        else
          return const_get(:Row)
        end
      end

      # compiles the select clause
      def compile_select( conditions, options )
        if options[:columns]
          cols = {}
          options[:columns].each do | name | cols[name] = columns[name] end
        else
          cols = columns
        end
        sql = "SELECT " + cols.keys.map{ | field | Database.quote_ident( field ) }.join( "," ) + " FROM "
        sql += full_name
        sql += compile_where( conditions )
        sql += compile_order( options[:order] ) if options[:order] || default_order
        sql = compile_distinct( sql, cols, options[:distinct] ) if options[:distinct]
        sql += compile_limit( options[:limit] ) if options[:limit]
        sql += compile_offset( options[:offset] ) if options[:offset]
        sql
      end

      def compile_distinct( inner_sql, cols, distinct )
        distinct = [distinct] unless distinct.instance_of?( Array )
        distinct.each do | field |
          raise CriticalError, "condition key '#{field}' not a column in table '#{table_name}'" unless columns.keys.member?( field.to_sym )
        end
        sql = "SELECT DISTINCT ON("
        sql += distinct.map{|f| Database.quote_ident(f)}.join(',')
        sql += ") "
        sql += cols.keys.map{ | field | Database.quote_ident( field ) }.join(',')
        sql += " FROM (#{inner_sql}) AS t1"
        sql
      end

      # returns the columns to be used for joining
      def join_columns( join_table ) # :nodoc:
        join_table.primary_keys.select{|f| columns.key?(f)}
      end

    end

  end

end

