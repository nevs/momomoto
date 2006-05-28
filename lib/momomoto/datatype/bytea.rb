
module Momomoto
  module Datatype
    class Bytea < Base

      def filter_get( value )
        Database.unescape_bytea( value ) if value
      end

      def self.escape( input )
        input.nil? ? "NULL" : "'" + Database.escape_bytea( input ) + "'"
      end
    
    end
  end
end

