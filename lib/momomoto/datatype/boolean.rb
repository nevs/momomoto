module Momomoto
  module Datatype
    class Boolean < Base

      def filter_set( value )
        case value
          when true, 1, 't', 'true', 'on' then true
          when false, 0, 'f', 'false', 'off' then false
          else not_null? ? false : nil
        end
      end

      def escape( input )
        case input
          when true, 1, 't', 'true', 'on' then "'t'"
          when false, 0, 'f', 'false', 'off' then "'f'"
          else "NULL"
        end
      end

    end
  end
end
