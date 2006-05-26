module Momomoto
  module Datatype
    class Boolean < Base

      def filter_set( value )
        if not_null?
          case value
            when true, 1, 't', 'true' then true
            else false
          end
        else
          case value
            when true, 1, 't', 'true' then true
            when false, 0, 'f', 'false' then false
            else nil
          end
        end
      end
    
      def self.escape( input )
        case input 
          when true then "'t'"
          when false then "'f'"
          else "NULL"
        end
      end

    end
  end
end
