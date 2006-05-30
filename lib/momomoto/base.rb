
## Momomoto is a database abstraction layer
module Momomoto

  ## base exception for all exceptions thrown by Momomoto
  class Error < StandardError; end

  class CriticalError < Error; end

  ## Momomoto base class for Table, Procedure and Join
  class Base

    class << self

      # guesses the schema name of the table this class works on
      def construct_schema_name( classname ) # :nodoc:
        # Uncomment these lines to derive the schema from the enclosing namespace of the class
        schema = classname.split('::')[-2]
        schema ? schema.downcase.gsub(/[^a-z_0-9]/, '') : nil
        nil
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
          raise CriticalError unless columns.keys.member?( key )
          where = where_append( where, columns[key].compile_rule( key, value ) )
        end
        where
      end

      # append where string
      def where_append( where, append ) # :nodoc:
        ( where.empty? ? ' WHERE ' : where + ' AND ' ) + append
      end

    end

  end

end

