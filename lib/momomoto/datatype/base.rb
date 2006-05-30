
module Momomoto

  DEBUG = false

  module Datatype
    # base class for all datatypes
    class Base
      # get the default value for this column
      # returns false if none exists 
      def default
        @default
      end

      # is this column a not null column
      def not_null?
        @not_null
      end

      def initialize( row = nil )
        @not_null = row.respond_to?(:is_nullable) && row.is_nullable == "NO"
        @default = row.respond_to?( :column_default) && row.column_default
      end
      
      # values are filtered by this function when being set
      def filter_set( value ) # :nodoc:
        case value
          when nil, '' then nil
          else value
        end
      end

      # values are filtered by this function when being get
      def filter_get( value ) # :nodoc:
        value
      end

      def self.escape( input )
        input.nil? ? "NULL" : "'" + Database.escape_string( input.to_s ) + "'"
      end

      def compile_rule( field_name, value ) # :nodoc:
        case value
          when nil then
            raise Error, "nil values not allowed here"
          when Array then
            raise Error, "empty array conditions are not allowed" if value.empty?
            raise Error, "nil values not allowed in compile_rule" if value.member?( nil )
            "#{field_name} IN (#{value.map{ | v | escape(filter_set(v)) }.join(',') })"
          when Hash then
            raise Error, "empty hash conditions are not allowed" if value.empty?
            rules = []
            value.each do | op, v |
              raise Error, "nil values not allowed in compile_rule" if v == nil
              rules << "#{field_name} #{self.class.operator_sign(op)} #{escape(filter_set(v))}"
            end
            rules.join( " AND " )
          else
            "#{field_name} = #{escape(filter_set(value))}"
        end
      end

      def self.operator_sign( op )
        case op
          when :le then '<='
          when :lt then '<'
          when :ge then '>='
          when :gt then '>'
          when :eq then '='
          when :ne then '<>'
          else
            raise CriticalError, "unsupported operator"
        end
      end

      def escape( input )
        self.class.escape( input )
      end
 
    end

  end
end

