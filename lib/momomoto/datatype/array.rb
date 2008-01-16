
require 'momomoto/datatype/array/base'
require 'momomoto/datatype/array/integer'
require 'momomoto/datatype/array/text'

module Momomoto
  module Datatype

    # Represents the data type Array.
    class Array

      # Creates a new instance of the special data type, setting +not_null+
      # and +default+ according to the values from Information Schema.
      def self.new( row = nil )
        subtype = nil
        if row.respond_to?( :udt_name ) && row.udt_name
          subtype = row.udt_name.gsub(/^_/,"")
        end
        subtype ||= 'text'
        Momomoto::Datatype::Array.const_get(subtype.capitalize).new( row )
      end

    end
  end
end
