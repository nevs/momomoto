
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

  end

end
