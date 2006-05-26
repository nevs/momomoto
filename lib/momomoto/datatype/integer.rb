module Momomoto
  module Datatype
    class Integer < Base
    
      def filter_set( value )
        value == nil ? nil : value.to_i
      end
      
      def filter_get( value )
        value == nil ? nil : value.to_i
      end
      
    end
  end
end
