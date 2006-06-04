module Momomoto
  module Datatype
    class Inet < Text

      def filter_get( value )
        case value
          when nil, '' then nil
          else value
        end
      end
    
      def filter_set( value )
        case value
          when nil, '' then nil
          else value
        end
      end
    
    end
  end
end
