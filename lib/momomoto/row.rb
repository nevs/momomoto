
module Momomoto
  # base class for all Rows
  class Row

    def self.table
      class_variable_get( :@@table )
    end

    def initialize( data = [] )
      @data = data
    end

    def new_record?
      @new_record
    end

    # write the row to the database
    def write
      class_variable_get( :@@table ).write( self )
    end

    # delete the row
    def delete
      class_variable_get( :@@table ).delete( self )
    end

  end

end
