
module Momomoto
  module Datatype
    class Numeric < Base
    
      def filter_set( value )
        value == nil ? nil : value.to_f
      end
      
    end
  end
end
