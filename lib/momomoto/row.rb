
module Momomoto
  # base class for all Rows
  class Row

    # undefing fields to avoid conflicts
    undef :id,:type

    def self.table
      @table
    end

    def self.columns
      @columns
    end

    def []( fieldname )
      get_column( fieldname )
    end

    def []=( fieldname, value )
      set_column( fieldname, value )
    end

    def ==( other )
      @data == other.instance_variable_get( :@data )
    end

    def dirty
      @dirty
    end

    def dirty?
      @dirty.length > 0
    end

    def mark_dirty( field )
      field = field.to_sym
      @dirty.push( field ) if not @dirty.member?( field )
    end

    def clean_dirty
      @dirty = []
    end

    def initialize( data = [] )
      @data = data
      @new_record = false
      clean_dirty
    end

    def new_record?
      @new_record
    end

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
      self.class.table.columns.keys.each do | key |
        hash[key] = self[key]
      end
      hash
    end

    # generic setter for column values
    def set_column( column, value )
      table = self.class.table
      if not new_record? and table.primary_keys.member?( column.to_sym )
        raise Error, "Setting primary keys(#{column}) is only allowed for new records"
      end
      value = table.columns[column.to_sym].filter_set( value )
      index = table.column_order.index( column.to_sym )
      if !table.columns[column.to_sym].equal( value, @data[index] )
        mark_dirty( column )
        @data[index] = value
      end
    end

    # generic getter for column values
    def get_column( column )
      table = self.class.table
      index = table.column_order.index( column.to_sym )
      if table.columns[column.to_sym].respond_to?( :filter_get )
        table.columns[column.to_sym].filter_get( @data[index] )
      else
        @data[index]
      end
    end

  end

end

