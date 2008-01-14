
## Momomoto is a database abstraction layer for PostgreSQL
module Momomoto

  @debug = false

  class << self

    # Getter and setter for debugging.
    # If +debug+ evaluates to +true+ then all SQL queries to the database
    # are printed to STDOUT.
    attr_accessor :debug

    # Returns an instance of Order::Lower where +args+ is either a single
    # or array of +Symbol+ representing columns.
    #
    # Eases the use of class Order::Lower. You can use it whenever selecting
    # rows or in #default_order.
    #
    #   order_lower = Momomoto.lower( :person )
    #     => #<Momomoto::Order::Lower:0x5184131c @fields=[:person]>
    #   Table.select( {}, {:order => order} )
    #     => returns Table's rows ordered case-insensitively by column person
    def lower( *args )
      Momomoto::Order::Lower.new( *args )
    end

    # Returns an instance of Order::Asc where +args+ is either a single
    # or array of +Symbol+ representing columns.
    #
    # Eases the use of class Order::Asc. You can use it whenever selecting
    # rows or in #default_order.
    #
    #   order_lower = Momomoto.asc( :person )
    #     => #<Momomoto::Order::Asc:0x5184131c @fields=[:person]>
    #   Table.select( {}, {:order => order} )
    #     => returns Table's rows ordered asc by column person
    def asc( *args )
      Momomoto::Order::Asc.new( *args )
    end

    # Returns an instance of Order::Asc where +args+ is either a single
    # or array of +Symbol+ representing columns.
    #
    # Eases the use of class Order::Desc. You can use it whenever selecting
    # rows or in #default_order.
    #
    #   order_lower = Momomoto.lower( :person )
    #     => #<Momomoto::Order::Desc:0x5184131c @fields=[:person]>
    #   Table.select( {}, {:order => order} )
    #     => returns Table's rows ordered desc by column person
    def desc( *args )
      Momomoto::Order::Desc.new( *args )
    end

  end

  # Base exception for all exceptions thrown by Momomoto
  class Error < StandardError; end

  # Thrown when datatype conversion fails and if a +block+ given to
  # Table#select_or_new does not act on all primary keys.
  class ConversionError < Error; end

  # Thrown when a critical error occurs.
  class CriticalError < Error; end
  
  # Thrown when multiple values are found in Table#select_or_new or
  # Table#select_single.
  class Too_many_records < Error; end

  # Thrown when no row was found in Table#select_single.
  class Nothing_found < Error; end


  ## Momomoto base class for Table and Procedure
  class Base

    class << self

      def momomoto_attribute_reader( name )
        singleton = self.instance_eval{class << self; self; end}
        varname = "@#{name}"
        # define getter method
        singleton.send(:define_method, name) do | *values |
          if not instance_variable_defined?( varname )
            initialize
          end
          instance_variable_get( varname )
        end
      end

      def momomoto_attribute( name )
        singleton = self.instance_eval{class << self; self; end}
        varname = "@#{name}"
        settername = "#{name}="
        # define getter method
        singleton.send(:define_method, name) do | *values |
          if values[0]
            send( settername, values[0] )
          else
            if not instance_variable_defined?( varname )
              initialize
            end
            instance_variable_get( varname )
          end
        end
        # define setter method
        singleton.send(:define_method, settername) do | value |
          instance_variable_set( varname, value )
        end
      end

      def initialize
        return if instance_variable_defined?( :@initialized )

        @schema_name ||= construct_schema_name( self.name )
        @logical_operator ||= 'AND'

        self.initialized = true
      end

    end

    # The schema name of the table this class operates on. Invokes
    # #schema_name= if +schema_name+ is given as parameter. Returns
    # +@schema_name+
    momomoto_attribute :schema_name

    # The logical operator is used in #compile_where and defines
    # the top level logical relation for where clauses.
    momomoto_attribute_reader :logical_operator

    class << self

      # Set the default logical operator for constraints. AND and OR are
      # supported.
      # See Table#select for usage of logical operators.
      def logical_operator=( value )
        @logical_operator = case value
          when /and/i then "AND"
          when /or/i then "OR"
          else raise Momomoto::Error, "Unsupported logical operator"
        end
      end

     protected

      # Getter and setter used for marking tables as initialized.
      attr_accessor :initialized

      # Guesses the schema name of the table this class works on.
      def construct_schema_name( classname )
        # Uncomment these lines to derive the schema from the enclosing namespace of the class
        #schema = classname.split('::')[-2]
        #schema ? schema.downcase.gsub(/[^a-z_0-9]/, '') : nil
        'public'
      end

      # Get the database connection.
      def database # :nodoc:
        Momomoto::Database.instance
      end

      # compiles the where-clause of the query
      def compile_where( conditions )
        conditions ||= {}
        where = compile_expression( conditions, logical_operator )
        where.empty? ? '' : " WHERE #{where}"
      end

      # compiles subexpressions of the where-clause
      def compile_expression( conditions, operator )
        where = []
        case conditions
          when Array then
            conditions.each do | value |
              expr = compile_expression( value, operator )
              where << expr if expr.length > 0
            end
          when Hash then
            conditions.each do | key , value |
              key = key.to_sym if key.kind_of?( String )
              case key
                when :OR,:AND then
                  expr = compile_expression( value, key.to_s )
                  where << "(#{expr})" if expr.length > 0
                else
                  raise CriticalError, "condition key '#{key}' not a column in table '#{table_name}'" unless columns.keys.member?( key )
                  where << columns[key].compile_rule( key, value )
              end
            end
        end
        where.join( " #{operator} ")
      end


      # Compiles the sql statement defining the limit
      #
      #   #selects five feeds
      #   five_feeds = Feeds.select( {},{:limit => 5} )
      def compile_limit( limit )
        " LIMIT #{Integer(limit)}"
       rescue => e
        raise Error, e.to_s
      end

      # compiles the sql statement defining the offset
      #
      #   #selects five feeds ommitting the first 23 rows
      #   five_feeds = Feeds.select( {}, {:offset => 23, :limit => 5} )
      def compile_offset( offset )
        " OFFSET #{Integer(offset)}"
       rescue => e
        raise Error, e.to_s
      end

      # compiles the sql statement defining the table order
      def compile_order( order )
        order = default_order if not order
        order = [ order ] if not order.kind_of?( Array )
        order = order.map do | field |
          if field.kind_of?( Momomoto::Order )
            field.to_sql( columns )
          else
            raise Momomoto::Error if not field.kind_of?( String ) and not field.kind_of?( Symbol )
            raise Momomoto::Error if not columns.keys.member?( field.to_sym )
            field.to_s
          end
        end
        " ORDER BY #{order.join(',')}"
      end

      # Constructs the Row class for the given table or procedure +table+.
      # If +columns+ is given as parameter to this method all setter and getter
      # for the fields which are not included in columns will be removed.
      #
      # See Table#select for how this can be useful when only some columns are
      # needed.
      #
      # module Methods can be used to modify setter and getter methods for columns.
      # Methods is included to the row class after StandardMethods which holds all
      # default accessors. That's why you can define your own accessors in Methods.
      #
      # See Row#set_column and Row#get_column for more information on this.
      def initialize_row( row, table, columns = table.columns )

        const_set( :Methods, Module.new ) if not const_defined?( :Methods )
        row.const_set( :StandardMethods, Module.new ) if not row.const_defined?( :StandardMethods )

        if not row.ancestors.member?( Momomoto::Row )
          raise CriticalError, "Row is not inherited from Momomoto::Row"
        end

        row.instance_eval do instance_variable_set( :@table, table ) end
        row.instance_eval do instance_variable_set( :@columns, columns ) end
        row.instance_eval do instance_variable_set( :@column_order, columns.keys ) end

        define_row_accessors( row.const_get( :StandardMethods ), table, columns )

        row.instance_eval do
          include row.const_get( :StandardMethods )
          include table.const_get( :Methods )
        end

        if table.columns.keys.length != columns.keys.length
          unused = table.columns.keys - columns.keys
          unused.each do | field |
            row.class_eval do
              undef_method field if row.instance_methods.member?( "#{field}" )
              undef_method "#{field}=" if row.instance_methods.member?( "#{field}=" )
            end
          end
        end

      end

      # Defines row setter and getter in the module StandardMethods which
      # is later included in the Row class.
      def define_row_accessors( method_module, table, columns )
        columns.each_with_index do | ( field_name, data_type ), index |
          method_module.instance_eval do
            # define getter for row class
            if data_type.respond_to?( :filter_get )
              define_method( field_name ) do
                data_type.filter_get( instance_variable_get(:@data)[index] )
              end
            else
              define_method( field_name ) do
                instance_variable_get(:@data)[index]
              end
            end

            # define setter for row class
            define_method( "#{field_name}=" ) do | value |
              if not new_record? and table.primary_keys.member?( field_name )
                raise Error, "Setting primary keys(#{field_name}) is only allowed for new records"
              end
              store = instance_variable_get(:@data)
              value = data_type.filter_set( value )
              if !data_type.equal( value, store[index] )
                mark_dirty( field_name )
                store[index] = value
              end
            end

          end
        end
      end

    end

  end

end

