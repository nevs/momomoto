module Momomoto
  module Datatype
    class Integer < Base

      def filter_set( value )
        case value
          when nil, '' then nil
          else Integer( value )
        end
       rescue => e
        raise Error, e.to_s
      end

    end
  end
end
