
## Momomoto is a database abstraction layer for PostgreSQL
module Momomoto

  class << self

    attr_accessor :debug

    def lower( *args )
      Momomoto::Order::Lower.new( *args )
    end

    def asc( *args )
      Momomoto::Order::Asc.new( *args )
    end

    def desc( *args )
      Momomoto::Order::Desc.new( *args )
    end

  end

  ## base exception for all exceptions thrown by Momomoto
  class Error < StandardError; end

  # thrown when datatype conversion fails
  class ConversionError < Error; end
  class CriticalError < Error; end

  class Too_many_records < Error; end
  class Nothing_found < Error; end


  ## Momomoto base class for Table and Procedure
  class Base

    class << self

      attr_reader :logical_operator

      # set the default logical operator for constraints
      def logical_operator=( value )
        @logical_operator = case value
          when /and/i then "AND"
          when /or/i then "OR"
          else raise Momomoto::Error, "Unsupported logical operator"
        end
      end

      # set the schema name of the table this class operates on
      def schema_name=( schema_name )
        @schema_name = schema_name
      end

      # get the schema name of the table this class operates on
      def schema_name( schema_name  = nil )
        return self.schema_name=( schema_name ) if schema_name
        if not instance_variable_defined?( :@schema_name )
          self.schema_name=( construct_schema_name( self.name ) )
        end
        @schema_name
      end

      protected

      attr_accessor :initialized

      # guesses the schema name of the table this class works on
      def construct_schema_name( classname )
        # Uncomment these lines to derive the schema from the enclosing namespace of the class
        #schema = classname.split('::')[-2]
        #schema ? schema.downcase.gsub(/[^a-z_0-9]/, '') : nil
        'public'
      end

      # get the database connection
      def database # :nodoc:
        Momomoto::Database.instance
      end

      # compiles the where-clause of the query
      def compile_where( conditions )
        conditions ||= {}
        where = compile_expression( conditions, logical_operator )
        where.empty? ? '' : " WHERE #{where}"
      end

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


      # compiles the sql statement defining the limit
      def compile_limit( limit )
        " LIMIT #{Integer(limit)}"
       rescue => e
        raise Error, e.to_s
      end

      # compiles the sql statement defining the offset
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

      # construct the Row class for the table
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

      # defines row setter and getter in the module StandardMethods which
      # is later included in the Row class
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

