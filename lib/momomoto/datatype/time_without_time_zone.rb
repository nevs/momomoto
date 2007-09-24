
require 'time'

module Momomoto
  module Datatype
    class Time_without_time_zone < Base

      def equal( a, b )
        escape(a) == escape(b)
      end

      def escape( value )
        case value
          when nil then 'NULL'
          when String then "'#{Database.escape_string(value)}'"
          else "'#{Database.escape_string(value.strftime('%H:%M:%S'))}'"
        end
      end

      def filter_set( value )
        case value
          when nil, '' then nil
          when ::Time then value
          when String then ::Time.parse( value )
          else raise Error
        end
       rescue => e
        raise ConversionError, 'Error while parsing time'
      end

    end
  end
end

