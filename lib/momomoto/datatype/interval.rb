module Momomoto
  module Datatype
    class Interval < Time_without_time_zone
    
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
