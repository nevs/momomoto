
require 'date'

module Momomoto
  module Datatype
    class Time_with_time_zone < Base
    
      def filter_get( value )
        case value
          when nil, '' then nil
          when String then DateTime.strptime( value, '%H:%M:%S')
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
