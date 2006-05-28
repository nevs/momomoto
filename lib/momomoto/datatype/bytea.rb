
module Momomoto
  module Datatype
    class Bytea < Base

      def self.escape( input )
        input.nil? ? "NULL" : "'" + Database.escape_bytea( input ) + "'"
      end
    
    end
  end
end

