module Momomoto
  module Datatype

    # Represents the data type Array.
    class Array < Base

      # Escapes +input+ to be saved in database.
      # Returns 'NULL' if +input+ is nil or empty. Otherwise escapes
      # using Database#escape_string
      def escape( input )
        if input.nil?
          "NULL"
        else
          "ARRAY[" + input.map{|m| "'" + Database.escape_string(m) + "'"}.join(',') + "]"
        end
      end

      # Values are filtered by this function when being set. See the
      # method in the appropriate derived data type class for allowed
      # values.
      def filter_set( value ) # :nodoc:
        value = [value] unless value.instance_of?( Array )
        value
      end

      # This method is used when compiling the where clause. No need
      # for direct use.
      def compile_rule( field_name, value ) # :nodoc:
        case value
          when nil then
            raise Error, "nil values not allowed for #{field_name}"
          when :NULL then
            field_name.to_s + ' IS NULL'
          when :NOT_NULL then
            field_name.to_s + ' IS NOT NULL'
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
            rules.join( " AND " )
          else
            field_name.to_s + ' @> ' + escape(filter_set(value))
        end
      end
      # Additional operators for instances of Array.
      # See Base#operator_sign
      def self.operator_sign( op )
        case op
          when :contains then '@>'
          when :contained then '<@'
          else
            super( op )
        end
      end

    end
  end
end
