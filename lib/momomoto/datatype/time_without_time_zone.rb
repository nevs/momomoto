
require 'time'

module Momomoto
  module Datatype
    class Time_without_time_zone < Base

      def self.escape( value )
        value == nil ? 'NULL' : "'#{PGconn.escape(value.strftime('%H:%M:%S'))}'"
      end
    
      def filter_get( value )
        case value
          when nil, '' then nil
          when ::Time then value
          when String then ::Time.parse( value )
          else raise Error
        end
       rescue => e
        raise Error, 'Error while parsing time'
      end

      def filter_set( value )
        filter_get( value ) 
      end

    end
  end
end

