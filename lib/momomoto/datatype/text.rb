module Momomoto
  module Datatype
    class Text < Base

      def equal( a, b )
        a.to_s == b.to_s
      end

      def escape( input )
        if input.nil? || input.to_s.empty?
          "NULL"
        else
          "E'" + Database.escape_string( input.to_s ) + "'"
        end
      end

      def self.operator_sign( op )
        case op
          when :like then 'LIKE'
          when :ilike then 'ILIKE'
          else
            super( op )
        end
      end

    end
  end
end
