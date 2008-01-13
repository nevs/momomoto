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
        elsif input.instance_of?( ::Array )
          "ARRAY[" + input.map{|m| "'" + Database.escape_string(m) + "'"}.join(',') + "]"
        else
          "'" + Database.escape_string(m) + "'"
        end
      end

      # Values are filtered by this function when being set. See the
      # method in the appropriate derived data type class for allowed
      # values.
      def filter_get( value ) # :nodoc:
        case value
          when ::Array then value
          when nil,"" then nil
          when "{}" then []
          when /^\{[^"]+(,[^"]+)*\}$/
            m = v.match(/^\{()\}$/)
            m[1].split(',')
          when /^\{"[^"]+"(,"[^"]+")*\}$/
            m = v.match(/^\{()\}$/)
            m[1].split(',').map{|e| e.gsub(/^"(.*)"$/, "\\1")}
          else
            raise Error, "Error parsing array value"
        end

      end

      # Values are filtered by this function when being set. See the
      # method in the appropriate derived data type class for allowed
      # values.
      def filter_set( value ) # :nodoc:
        value = [value] unless value.instance_of?( ::Array )
        value
      end

      # Get the default value for this Datatype.
      def default_operator
        "@>"
      end

      # This method is used when compiling the where clause. No need
      # for direct use.
      def compile_rule( field_name, value ) # :nodoc:
        case value
          when ::Array then
            raise Error, "empty or nil array conditions are not allowed for #{field_name}" if value.empty? or value.member?( nil )
            field_name.to_s + ' @> ' + escape(filter_set(value))
          else
            super
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