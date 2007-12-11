module Momomoto
  module Datatype

    # This class represents values of boolean type.
    class Boolean < Base

      # Values are filtered by this method when being set.
      # Returns true or false.
      # If the given +value+ cannot be converted to true or false
      # and NULL is not allowed, than again return false. Otherwise
      # return +nil+.
      def filter_set( value )
        case value
          when true, 1, 't', 'true', 'on' then true
          when false, 0, 'f', 'false', 'off' then false
          else not_null? ? false : nil
        end
      end

      # Converts the given +input+ to true or false if possible.
      # Otherwise returns NULL.
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
