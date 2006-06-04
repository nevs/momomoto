
module Momomoto
  module Datatype
    class Bytea < Base

      def filter_get( value )
        Database.unescape_bytea( value ) if value
      end

      def filter_set( value )
        value.nil? ? nil : Database.unescape_bytea( Database.escape_bytea( value ) )
      end

      def self.escape( input )
        input.nil? ? "NULL" : "'" + Database.escape_bytea( input.gsub( "''", "'" ) ) + "'"
      end
    
    end
  end
end

