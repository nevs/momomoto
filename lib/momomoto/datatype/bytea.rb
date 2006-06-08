
module Momomoto
  module Datatype
    class Bytea < Base

      def escape( input )
        input.nil? ? "NULL" : "'" + Database.escape_bytea( input ) + "'"
      end
    
    end
  end
end

