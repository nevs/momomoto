
require 'date'

module Momomoto
  module Datatype
    class Timestamp_without_time_zone < Base
    
      def filter_get( value )
        case value
          when nil, '' then nil
          when String then DateTime.strptime( value, '%Y-%m-%d %H:%M:%S')
          else raise Error
        end
       rescue => e
        raise Error, "Error while parsing Time"
      end

      def filter_set( value )
        filter_get( value )
      end

    end
  end
end
