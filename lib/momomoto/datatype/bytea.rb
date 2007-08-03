
module Momomoto
  module Datatype
    class Bytea < Base

      def escape( input )
        input.nil? ? "NULL" : "E'" + Database.escape_bytea( input ) + "'"
      end

    end
  end
end

