module Momomoto
  module Datatype

    # Represents data type Integer.
    class Integer < Base

      # Values are filtered by this function when being set.
      # Force +value+ to Integer and raise if this fails or return +nil+
      # if +value+ is nil or empty.
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
