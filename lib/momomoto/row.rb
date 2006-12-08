
module Momomoto
  # base class for all Rows
  class Row

    # undefing id to avoid conflicts with fields named id
    undef :id

    def self.table
      class_variable_get( :@@table )
    end

    def []( fieldname )
      send( fieldname )
    end

    def []=( fieldname, value )
      send( fieldname.to_s + '=', value )
    end

    def dirty?
      @dirty
    end

    def dirty=( value )
      @dirty = !!value
    end

    def initialize( data = [] )
      @data = data
      @new_record = false
      @dirty = false
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

  end

end
