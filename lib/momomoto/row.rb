
module Momomoto

  # Base class for all Rows.
  class Row

    # undefing fields to avoid conflicts
    undef :id,:type

    # Getter for the table this Row is using.
    def self.table
      @table
    end

    # Getter for the columns of the table of the Row.
    def self.columns
      @columns
    end

    # Getter for the order of columns. The order is simply built from
    # +columns+.keys.
    def self.column_order
      @column_order
    end

    # Getter for the given +fieldname+.
    #
    #   feed = Feeds.select( {:url => 'https://www.c3d2.de/news-atom.xml' ).first
    #   feed[:url] == 'https://www.c3d2.de/news-atom.xml'
    #     => true
    #   
    def []( fieldname )
      get_column( fieldname )
    end

    # Sets +fieldname+ to +value+.
    #
    #   feed = Feeds.select( {:url => 'https://www.c3d2.de/news-atom.xml' ).first
    #   feed[:url_host] = 'https://www.c3d2.de/'
    def []=( fieldname, value )
      set_column( fieldname, value )
    end

    # Compares the +@data+ value of the row with +other+.
    def ==( other )
      @data == other.instance_variable_get( :@data )
    end

    # Getter for +dirty+ which holds all changed fields of a row.
    def dirty
      @dirty
    end

    # Returns true if there are fields in +dirty+.
    def dirty?
      @dirty.length > 0
    end

    # Marks a field as dirty.
    def mark_dirty( field )
      field = field.to_sym
      @dirty.push( field ) if not @dirty.member?( field )
    end

    # Removes all fields from +dirty+.
    def clean_dirty
      @dirty = []
    end

    # Creates a new Row instance.
    def initialize( data = [] )
      @data = data
      @new_record = false
      clean_dirty
    end

    # Returns true if the row is newly greated.
    def new_record?
      @new_record
    end

    # Sets +@new_record+ to +value+. 
    def new_record=( value )
      @new_record = !!value
    end

    # write the row to the database
    def write
      self.class.table.write( self )
    end

    # delete the row
    def delete
      self.class.table.delete( self )
    end

    # convert row to hash
    def to_hash
      hash = {}
      self.class.columns.keys.each do | key |
        hash[key] = self[key]
      end
      hash
    end

    # Generic setter for column values. You should use this method when
    # you are defining own setter. This is useful for preprocessing +value+
    # before it is written to database:
    #
    #   class Person < Momomoto::Table
    #     module Methods
    #       def nickname=( value )
    #         set_column( :nickname, value.downcase )
    #       end
    #     end
    #   end
    #
    # This defines a custom setter nickname which invokes downcase 
    # on the given +value+.
    def set_column( column, value )
      raise "Unknown column #{column}" if not self.class.column_order.member?( column.to_sym )
      table = self.class.table
      if not new_record? and table.primary_keys.member?( column.to_sym )
        raise Error, "Setting primary keys(#{column}) is only allowed for new records"
      end
      value = table.columns[column.to_sym].filter_set( value )
      index = self.class.column_order.index( column.to_sym )
      if !table.columns[column.to_sym].equal( value, @data[index] )
        mark_dirty( column )
        @data[index] = value
      end
    end

    # generic getter for column values
    def get_column( column )
      raise "Unknown column #{column}" if not self.class.column_order.member?( column.to_sym )
      table = self.class.table
      index = self.class.column_order.index( column.to_sym )
      if table.columns[column.to_sym].respond_to?( :filter_get )
        table.columns[column.to_sym].filter_get( @data[index] )
      else
        @data[index]
      end
    end

  end

end

