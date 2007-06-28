
module Momomoto

  class Order

    attr_accessor :fields

    def initialize( *fields )
      @fields = fields.flatten
      @fields.each do | field |
        raise Error if not columns.keys.member?( field.to_sym )
      end
    end

    def to_sql( columns )
      sql = []
      fields.each do | field |
        if field.kind_of?( Momomoto::Order )
          sql << function( field.to_sql( columns ) )
        else
          raise Momomoto::Error if not columns.keys.member?( field.to_sym )
          sql << function( field  )
        end
      end
      sql.join(',')
    end

    class Lower < Order
      def initialize( *fields )
        fields = fields.flatten
        fields.each do | field |
          raise Error if not columns.keys.member?( field.to_sym )
          raise Error, "Asc and Desc are only allowed as toplevel order elements" if field.kind_of?( Asc ) or field.kind_of?( Desc )
        end
        @fields = fields
      end

      def function( argument )
        argument = [ argument ] if not argument.kind_of?( Array )
        argument = argument.map{|a| "lower(#{a})"}
        argument.join(',')
      end
    end

    class Asc < Order
      def function( argument )
        "#{argument} asc"
      end
    end

    class Desc < Order
      def function( argument )
        "#{argument} desc"
      end
    end

  end

end

