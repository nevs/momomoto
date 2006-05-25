
module Momomoto
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

      # mark this datatype as primary key
      def primary_key=( pk ) # :nodoc:
        @primary_key = !!pk
      end

      # is this column a primary key
      def primary_key?
        @primary_key
      end

      def initialize( row = nil )
        @not_null = row.respond_to?(:is_nullable) && row.is_nullable == "NO"
        @default = row.respond_to?( :column_default) && row.column_default
        @primary_key = false
      end
      
      def filter_set( value ) # :nodoc:
        value.nil? ? nil : value.to_s.gsub('\\', '')
      end

      def filter_get( value ) # :nodoc:
        value
      end

      def self.escape( input )
        input.nil? ? "NULL" : "'" + PGconn.escape( input.to_s ) + "'"
      end

      def compile_rule( field_name, value )
        case value
          when String, Symbol, Numeric then
            "#{field_name} = #{escape(filter_set(value))}"
          when Array then
            raise Error, "empty array conditions are not allowed" if value.empty?
            raise Error, "nil values not allowed in compile_rule" if value.member?( nil )
            "#{field_name} IN (#{value.map{ | v | escape(filter_set(v)) }.join(', ') })"
          when Hash then
            raise Error, "empty hash conditions are not allowed" if value.empty?
            rules = []
            value.each do | op, v |
              raise Error, "nil values not allowed in compile_rule" if v == nil
              rules << "#{field_name} #{self.class.operator_sign(op)} #{escape(filter_set(v))}"
            end
            rules.join( " AND " )
          else
            raise Error, "Unsupported class: #{value.class}"
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

