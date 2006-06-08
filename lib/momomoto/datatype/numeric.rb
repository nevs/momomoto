
module Momomoto
  module Datatype
    class Numeric < Base
    
      def filter_set( value )
        case value
          when nil, '' then nil
          else Float( value )
        end
       rescue => e
        raise Error, e.to_s
      end
      
    end
  end
end
