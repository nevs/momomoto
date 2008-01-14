module Momomoto
  module Datatype

    # This class represents data type Inet which is an IPv4 or IPv6 host or address.
    class Inet < Text

      # Values are filtered by this method when being set.
      # Returns nil if +value+ is empty or nil.
      def filter_set( value )
        case value
          when nil, '' then nil
          else value
        end
      end

    end
  end
end
