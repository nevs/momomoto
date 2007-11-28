
require 'date'

module Momomoto
  module Datatype

    # Represents the data type Date.
    class Date < Base

      # Values are filtered by this function when being set.
      # Returns ruby's Date or tries to transform a String to Date.
      # Returns nil if +value+ is empty or nil.
      def filter_set( value )
        case value
          when nil,'' then nil
          when ::Date then value
          when String then ::Date.parse( value, '%Y-%m-%d' )
          else raise Error
        end
       rescue => e 
        raise ConversionError, "parse Error in Date #{e}"
      end
    
    end
  end
end

