
module Momomoto
  module Datatype

    # This class is used for Binary Data (Byte Array).
    class Bytea < Base

      # Escapes +input+ using Database#escape_bytea or returns NULL if
      # +input+ is +nil+.
      def escape( input )
        input.nil? ? "NULL" : "E'" + Database.escape_bytea( input ) + "'"
      end

    end
  end
end

