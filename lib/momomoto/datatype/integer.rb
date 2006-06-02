module Momomoto
  module Datatype
    class Integer < Base

      def filter_get( value )
        case value
          when nil, '' then nil
          else Integer( value )
        end
       rescue => e
        raise Error, e.to_s
      end

      def filter_set( value )
        filter_get( value )
      end

    end
  end
end
