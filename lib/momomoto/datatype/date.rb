
require 'date'

module Momomoto
  module Datatype
    class Date < Base

      def filter_get( value )
        case value
          when nil then nil
          when ::Date then value
          when String then ::Date.parse( value, '%Y-%m-%d' )
          else raise Error
        end
       rescue => e 
        raise Error, "parse Error in Date #{e}"
      end
    
      def filter_set( value )
        case value
          when nil then nil
          when ::Date then value
          when String then ::Date.parse( value, '%Y-%m-%d' )
          else raise Error
        end
       rescue => e
        raise Error, "parse Error in Date: #{e}"
      end
    
    end
  end
end

