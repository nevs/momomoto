
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

      def initialize( row = nil )
        @not_null = row.respond_to?(:is_nullable) && row.is_nullable == "NO"
        @default = row.respond_to?( :column_default) && row.column_default
      end

      # values are filtered by this function when being set
      def filter_set( value ) # :nodoc:
        value
      end

      def equal( a, b )
        a == b
      end

      def escape( input )
        input.nil? ? "NULL" : "'" + Database.escape_string( input.to_s ) + "'"
      end

      # this functions is used for compiling the where clause
      def compile_rule( field_name, value ) # :nodoc:
        case value
          when nil then
            raise Error, "nil values not allowed for #{field_name}"
          when :NULL then
            field_name.to_s + ' IS NULL'
          when :NOT_NULL then
            field_name.to_s + ' IS NOT NULL'
          when Array then
            raise Error, "empty array conditions are not allowed for #{field_name}" if value.empty?
            raise Error, "nil values not allowed in compile_rule for #{field_name}" if value.member?( nil )
            field_name.to_s + ' IN (' + value.map{ | v | escape(filter_set(v)) }.join(',') + ')'
          when Hash then
            raise Error, "empty hash conditions are not allowed for #{field_name}" if value.empty?
            rules = []
            value.each do | op, v |
              raise Error, "nil values not allowed in compile_rule for #{field_name}" if v == nil
              v = [v] if not v.kind_of?( Array )
              if op == :eq # use IN if comparing for equality
                rules << compile_rule( field_name, v )
              else
                v.each do | v2 |
                  rules << field_name.to_s + ' ' + self.class.operator_sign(op) + ' ' + escape(filter_set(v2))
                end
              end
            end
            rules.join( " OR " )
          else
            field_name.to_s + ' = ' + escape(filter_set(value))
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

    end

  end
end

