
module Momomoto

  # this class implements access to stored procedures
  # it must not be used directly but you should inherit from this class
  class Procedure < Base

    class << self

      def initialize_procedure # :nodoc:

        unless class_variables.member?( '@@procedure_name' )
          procedure_name( construct_procedure_name( self.name ) )
        end

        unless class_variables.member?( '@@schema_name' )
          schema_name( construct_schema_name( self.name ) )
        end

        unless class_variables.member?( '@@parameter' )
          parameter( database.fetch_procedure_parameter( procedure_name ) )
          raise CriticalError if not parameter
        end

        unless class_variables.member?( '@@columns' )
          columns( database.fetch_procedure_columns( procedure_name ) )
          raise CriticalError if not columns
        end

        const_set( :Row, Class.new( Momomoto::Row ) ) if not const_defined?( :Row )
        initialize_row( const_get( :Row ), self )

        # mark class as initialized
        class_variable_set( :@@initialized, true)

      end

      # guesses the procedure name of the procedure this class works on
      def construct_procedure_name( classname ) # :nodoc:
        classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
      end

      # set the procedure name
      def procedure_name=( procedure_name )
        class_variable_set( :@@procedure_name, procedure_name )
      end

      # get the procedure name
      def procedure_name( procedure_name = nil )
        return self.procedure_name=( procedure_name ) if procedure_name
        begin
          class_variable_get( :@@procedure_name )
        rescue NameError
          construct_procedure_name( self.name )
        end
      end

      # get the full name of the procedure including schema if set
      def full_name # :nodoc:
        "#{ schema_name ? schema_name + '.' : ''}#{procedure_name}"
      end

      # set the parameter this procedures accepts
      def parameter=( parameter )
        class_variable_set( :@@parameter, parameter)
      end

      # get the parameter this procedure accepts
      def parameter( parameter = nil )
        return self.parameter=( parameter ) if parameter
        begin
          class_variable_get( :@@parameter )
        rescue NameError
          nil
        end
      end

      # get the columns of the resultset this procedure returns
      def columns=( columns )
        class_variable_set( :@@columns, columns)
      end

      # get the columns of the resultset this procedure returns
      def columns( columns = nil )
        return self.columns=( columns ) if columns
        begin
          class_variable_get( :@@columns )
        rescue NameError
          nil
        end
      end

      def compile_parameter( params ) # :nodoc:
        args = []
        parameter.each do | field_name, datatype |
          raise Error, "parameter #{field_name} not specified" if not params.include?( field_name )
          args << datatype.escape( params[field_name] )
        end
        args.join(',')
      end

      # execute the stored procedure
      def call( params = {}, conditions = {}, options = {} )
        initialize_procedure unless class_variables.member?('@@initialized')
        sql = "SELECT #{columns.keys.join(',')} FROM "
        sql += "#{full_name}(#{compile_parameter(params)})"
        sql += compile_where( conditions )
        sql += compile_order( options[:order] ) if options[:order]
        sql += compile_limit( options[:limit] ) if options[:limit]
        sql += ';'
        data = []
        database.execute( sql ).each do | row |
          data << const_get(:Row).new( row )
        end
        data
      end

    end

  end

end

