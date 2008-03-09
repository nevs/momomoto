
module Momomoto

  # This class implements access to stored procedures.
  # It must not be used directly but you should inherit from this class.
  class Procedure < Base

    # the procedure name of this class
    momomoto_attribute :procedure_name

    # the columns of the result set this procedure returns
    # a hash with the field names as keys and the datatype as values
    momomoto_attribute :columns

    class << self

      def initialize # :nodoc:
        return if initialized
        super

        @procedure_name ||= construct_procedure_name( self.name )
        @parameters ||= database.fetch_procedure_parameters( procedure_name )
        @columns ||= database.fetch_procedure_columns( procedure_name )

        const_set( :Row, Class.new( Momomoto::Row ) ) if not const_defined?( :Row )
        initialize_row( const_get( :Row ), self )

      end

      # guesses the procedure name of the procedure this class works on
      def construct_procedure_name( classname ) # :nodoc:
        classname.to_s.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
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
        initialize if not initialized
        @parameters
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
        if columns.length > 0
          sql = "SELECT #{columns.keys.join(',')} FROM "
        else
          sql = "SELECT "
        end
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

