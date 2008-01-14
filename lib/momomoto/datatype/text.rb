module Momomoto
  module Datatype

    # Represents the data type Text.
    class Text < Base

      # Compares two values and returns true if equal or false otherwise.
      # It is used to check if a row field has been changed so that only
      # changed fields are written to database.
      def equal( a, b )
        a.to_s == b.to_s
      end

      # Escapes +input+ to be saved in database.
      # Returns 'NULL' if +input+ is nil or empty. Otherwise escapes
      # using Database#quote
      def escape( input )
        if input.nil? || input.to_s.empty?
          "NULL"
        else
          Database.quote_string( input.to_s )
        end
      end

      # Additional operators for instances of Text.
      # See Base#operator_sign
      #
      #   # Selects all posts having "surveillance" in their content field
      #   # while ignoring case.
      #   Posts.select( :content => {:ilike => 'surveillance'} )
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
