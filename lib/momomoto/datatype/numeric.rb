
module Momomoto
  module Datatype

    # This class represents data type Numeric.
    class Numeric < Base

      # Values are filtered by this method when being set.
      # Converts +value+ to Float or returns nil if +value+ is nil or
      # empty.
      def filter_set( value )
        case value
          when nil, '' then nil
          else Float( value )
        end
      rescue => e
        raise ConversionError, e.to_s
      end

    end
  end
end
