
module Momomoto
  module Datatype
    class Numeric < Base
    
      def filter_get( value )
        value == nil ? nil : value.to_f
      end
      
      def filter_set( value )
        filter_get( value )
      end
      
    end
  end
end
