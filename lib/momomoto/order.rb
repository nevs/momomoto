
module Momomoto

  # This class is used to specify the order of returned +Row+s.
  # Whenever selecting rows you can use plain +Symbol+s for column names
  # or the builtin classes for having the result automatically sorted +asc+
  # ending, +desc+ending or case-insensitive with +lower+.
  #
  # When executing SELECT on tables the method Base#compile_order is
  # invoked, which compiles the order statement according to Table#default_order
  # if defined. This can be overwritten with options[:order] set as parameter
  # for the select method.
  #
  #   class Feeds < Momomoto::Table
  #     default_order Momomoto.desc( :last_changed )
  #     #equals default_order Momomoto::Order::Desc.new( :last_changed )
  #   end
  #
  #   newest_five_feeds = Feeds.select( {}, { :limit => 5} )
  #     => Returns the five rows from Feeds with the newest column last_changed
  # 
  # Now, if you want to get all feeds sorted by column title instead of
  # last_changed and also want to ignore case, do the following:
  #
  #   feeds_by_title = Feeds.select( {}, {:order => Momomoto::lower(:title)} )
  #
  # This overwrites the default value for order.
  #
  # You can also define multiple order statements at once, which are then
  # joined together.
  #
  #   class Feeds < Momomoto::Table
  #     default_order [Momomoto::desc(:last_changed), Momomoto::lower(:title)]
  #   end
  class Order

    # Getter and setter methods for +fields+. +fields+ are +Symbol+s
    # representing the columns the Order class operates on.
    attr_accessor :fields

    # Creates a new instance of Order and flattens the given parameter
    # +fields+.
    #
    # Usage:
    #   Momomoto::Order.new(:url_class, [:url, :title])
    def initialize( *fields )
      @fields = fields.flatten
    end

    # This method is used to build the SQL statement from the given
    # +columns+ and their class. This method is only invoked from
    # Base#compile_order.
    def to_sql( columns )
      sql = []
      fields.each do | field |
        if field.kind_of?( Momomoto::Order )
          sql << function( field.to_sql( columns ) )
        else
          raise Momomoto::Error, "Unknown field #{field} in order" if not columns.keys.member?( field.to_sym )
          sql << function( field  )
        end
      end
      sql.join(',')
    end

    # This class is used for case-insensitive orders. It is derived from
    # the Order class where you can find more information on usage.
    class Lower < Order

      # Creates a new instance of Lower and flattens the given parameter
      # +fields+. 
      # Throws Error if presented with fields that are either instances of 
      # Order::Asc or Order::Desc.
      #
      # Usage:
      #   Momomoto::Order::Lower.new(:author, [:title, :publisher])
      def initialize( *fields )
        fields = fields.flatten
        fields.each do | field |
          raise Error, "Asc and Desc are only allowed as toplevel order elements" if field.kind_of?( Asc ) or field.kind_of?( Desc )
        end
        @fields = fields
      end

      # translates all +argument+s to the SQL statement.
      # returns the joined arguments.
      def function( argument )
        argument = [ argument ] if not argument.kind_of?( Array )
        argument = argument.map{|a| "lower(#{a})"}
        argument.join(',')
      end
    end

    # This class is used for ascending orders. It is derived from the
    # Order class where you can find more information on usage.
    class Asc < Order

      # translates +argument+ to SQL statement for ascending.
      def function( argument )
        "#{argument} asc"
      end
    end

    # This class is used for descending orders. It is derived from the
    # Order class where you can find more information on usage.
    class Desc < Order

      # translates +argument+ to SQL statement for descending.
      def function( argument )
        "#{argument} desc"
      end
    end

  end

end

