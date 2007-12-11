module Momomoto
  module Datatype

    # This class represents data type Integer.
    class Integer < Base

      # Values are filtered by this method when being set.
      # Converts +value+ to Integer or return +nil+ if +value+ is nil or empty.
      # Raises ConversionError if converting fails.
      def filter_set( value )
        case value
          when nil, '' then nil
          else Integer( value )
        end
       rescue => e
        raise ConversionError, e.to_s
      end

    end
  end
end
