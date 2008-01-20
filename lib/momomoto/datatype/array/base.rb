module Momomoto
  module Datatype
    class Array

      # base datatype for array types
      class Base < Momomoto::Datatype::Base

        # Creates a new instance of the special data type, setting +not_null+
        # and +default+ according to the values from Information Schema.
        def initialize( row = nil )
          @not_null = row.respond_to?(:is_nullable) && row.is_nullable == "NO" ? true : false
          @default = row.respond_to?(:column_default) ? row.column_default : nil
        end

        # Escape and quote +input+ to be saved in database.
        # Returns 'NULL' if +input+ is nil or empty. Otherwise uses
        # Database#quote
        def escape( input )
          if input.nil?
            "NULL"
          elsif input.instance_of?( ::Array )
            if input.empty?
              "'{}'::#{array_type}[]"
            else
              "ARRAY[" + input.map{|m| Database.quote(m)}.join(',') + "]::#{array_type}[]"
            end
          else
            Database.quote( input )
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
            when /^\{("[^"]+"|[^",]+)(,("[^"]+"|[^",]+))*\}$/
              m = value.match(/^\{(.*)\}$/)
              values = []
              m[1].gsub( /("[^"]+"|[^",]+)/ ) do | element |
                if m = element.match(/^"(.*)"$/)
                  values << m[1]
                else
                  values << element
                end
              end
              values
            else
              raise Error, "Error parsing array value"
          end
        end

        # Values are filtered by this function when being set. See the
        # method in the appropriate derived data type class for allowed
        # values.
        def filter_set( value ) # :nodoc:
          value = [value] if value && !value.instance_of?( ::Array )
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
end
