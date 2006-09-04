
require 'date'

module Momomoto
  module Datatype
    class Timestamp_without_time_zone < Base

      def escape( value )
        case value
          when nil then 'NULL'
          when String then "'#{Database.escape_string(value)}'"
          else "'#{Database.escape_string(value.strftime('%Y-%m-%d %H:%M:%S'))}'"
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
        raise Error, "Error while parsing Timestamp"
      end

    end
  end
end
