
module Momomoto

  # This class implements access to stored procedures.
  # It must not be used directly but you should inherit from this class.
  class Procedure < Base

    class << self

      def initialize_procedure # :nodoc:

        @procedure_name ||= construct_procedure_name( self.name )
        @schema_name ||= construct_schema_name( self.name )
        @parameters ||= database.fetch_procedure_parameters( procedure_name )
        @columns ||= database.fetch_procedure_columns( procedure_name )
        @logical_operator ||= "AND"

        const_set( :Row, Class.new( Momomoto::Row ) ) if not const_defined?( :Row )
        initialize_row( const_get( :Row ), self )

        # mark class as initialized
        self.initialized = true

      end

      # guesses the procedure name of the procedure this class works on
      def construct_procedure_name( classname ) # :nodoc:
        classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
      end

      # sets the procedure name
      def procedure_name=( procedure_name )
        @procedure_name = procedure_name
      end

      # gets the procedure name
      def procedure_name( procedure_name = nil )
        return self.procedure_name=( procedure_name ) if procedure_name
        if not instance_variable_defined?( :@procedure_name )
          self.procedure_name = construct_procedure_name( self.name )
        end
        @procedure_name
      end

      # gets the full name of the procedure including schema if set
      def full_name # :nodoc:
        "#{ schema_name ? schema_name + '.' : ''}#{procedure_name}"
      end

      # sets the parameters this procedures accepts
      # example: parameters = {:param1=>Momomoto::Datatype::Text.new}
      def parameters=( *p )
        p = p.flatten
        @parameters = p
      end

      # gets the parameters this procedure accepts
      # returns an array of hashes with the field names as keys and the datatype as values
      def parameters( *p )
        return self.send( :parameters=, *p ) if not p.empty?
        initialize_procedure if not instance_variable_defined?( :@parameters )
        @parameters
      end

      # sets the columns of the result set this procedure returns
      # expects a hash with the field names as keys and the datatype as values
      def columns=( columns )
        @columns = columns
      end

      # gets the columns of the result set this procedure returns
      # returns a hash with the field names as keys and the datatype as values
      def columns( c = nil )
        return self.columns=( c ) if c
        initialize_procedure if not instance_variable_defined?( :@columns )
        @columns
      end

      def compile_parameter( params ) # :nodoc:
        args = []
        parameters.each do | parameter |
          field_name, datatype = parameter.to_a.first
          raise Error, "parameter #{field_name} not specified" if not params.member?( field_name )
          raise Error, "Not null fields(#{field_name}) need to be set in #{full_name}" if !params[field_name] && datatype.not_null?
          args << datatype.escape( params[field_name] )
        end
        args.join(',')
      end

      # executes the stored procedure
      def call( params = {}, conditions = {}, options = {} )
        initialize_procedure unless initialized
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

