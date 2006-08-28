
require 'time'

module Momomoto
  module Datatype
    class Time_without_time_zone < Base

      def escape( value )
        value == nil ? 'NULL' : "'#{Database.escape_string(value.strftime('%H:%M:%S'))}'"
      end

      def filter_set( value )
        case value
          when nil, '' then nil
          when ::Time then value
          when String then ::Time.parse( value )
          else raise Error
        end
       rescue => e
        raise Error, 'Error while parsing time'
      end

    end
  end
end

