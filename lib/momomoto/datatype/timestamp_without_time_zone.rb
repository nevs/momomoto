
require 'date'

module Momomoto
  module Datatype
    class Timestamp_without_time_zone < Base
    
      def filter_get( value )
        case value
          when nil, '' then nil
          when DateTime then value
          when String then DateTime.parse( value )
          else raise Error
        end
       rescue => e
        raise Error, "Error while parsing Timestamp"
      end

      def filter_set( value )
        filter_get( value )
      end

    end
  end
end
