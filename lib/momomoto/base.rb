
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


  ## Momomoto base class for Table, Procedure and Join
  class Base

    class << self

      # guesses the schema name of the table this class works on
      def construct_schema_name( classname ) # :nodoc:
        # Uncomment these lines to derive the schema from the enclosing namespace of the class
        #schema = classname.split('::')[-2]
        #schema ? schema.downcase.gsub(/[^a-z_0-9]/, '') : nil
        'public'
      end

      # set the schema name of the table this class operates on
      def schema_name=( schema_name )
        class_variable_set( :@@schema_name, schema_name )
      end

      # get the schema name of the table this class operates on
      def schema_name( schema_name  = nil )
        return self.schema_name=( schema_name ) if schema_name
        begin
          class_variable_get( :@@schema_name )
        rescue NameError
          construct_schema_name( self.name )
        end
      end

      # get the database connection
      def database # :nodoc:
        Momomoto::Database.instance
      end

      # compiles the where-clause of the query
      def compile_where( conditions ) # :nodoc:
        conditions = {} if not conditions
        where = ''
        conditions.each do | key , value |
          key = key.to_sym if key.kind_of?( String )
          raise CriticalError, "condition key '#{key}' not a column in table '#{table_name}'" unless columns.keys.member?( key )
          where = where_append( where, columns[key].compile_rule( key, value ) )
        end
        where
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
      def compile_order( order ) # :nodoc:
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

      # append where string
      def where_append( where, append ) # :nodoc:
        ( where.empty? ? ' WHERE ' : where + ' AND ' ) + append
      end

      # construct the Row class for the table
      def initialize_row( row, table ) # :nodoc:

        if not row.ancestors.member?( Momomoto::Row )
          raise CriticalError, "Row is not inherited from Momomoto::Row"
        end

        row.instance_eval do class_variable_set( :@@table, table ) end

        columns.each_with_index do | ( field_name, data_type ), index |
          row.instance_eval do
            # define getter for row class
            if not public_method_defined?( field_name )
              if data_type.respond_to?( :filter_get )
                define_method( field_name ) do
                  data_type.filter_get( instance_variable_get(:@data)[index] )
                end
              else
                define_method( field_name ) do
                  instance_variable_get(:@data)[index]
                end
              end
            end

            # define setter for row class
            setter_name = "#{field_name}="
            define_method( setter_name ) do | value |
              if not new_record? and table.primary_keys.member?( field_name )
                raise Error, "Setting primary keys(#{field_name}) is only allowed for new records"
              end
              store = instance_variable_get(:@data)
              value = data_type.filter_set( value )
              if store[index] != value
                instance_variable_set(:@dirty, true)
                store[index] = value
              end
            end

          end
        end

      end

    end

  end

end

