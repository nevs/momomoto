
module Momomoto
  # base class for all Rows
  class Row

    def self.table
      class_variable_get( :@@table )
    end

    def []( fieldname )
      send( fieldname )
    end

    def []=( fieldname, value )
      send( fieldname.to_s + '=', value )
    end

    def initialize( data = [] )
      @data = data
      @new_record = false
    end

    def new_record?
      @new_record
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
