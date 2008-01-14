
module Momomoto
  module Datatype

    # This class is used for Binary Data (Byte Array).
    class Bytea < Base

      # Escapes +input+ using Database#quote_bytea or returns NULL if
      # +input+ is nil.
      def escape( input )
        input.nil? ? "NULL" : Database.quote_bytea( input )
      end

    end
  end
end

