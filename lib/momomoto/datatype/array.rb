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
