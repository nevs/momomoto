module Momomoto
  module Datatype
    class Text < Base
    
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
