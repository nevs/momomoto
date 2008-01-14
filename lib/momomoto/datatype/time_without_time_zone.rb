
require 'time'

module Momomoto
  module Datatype

    # Represents the data type Time without time zone.
    class Time_without_time_zone < Base

      # Compares two values and returns true if equal or false otherwise.
      # It is used to check if a row field has been changed so that only
      # changed fields are written to database.
      # Escapes before comparing.
      def equal( a, b )
        escape(a) == escape(b)
      end

      # Escapes +value+ to be saved in database.
      # Returns 'NULL' if +value+ is nil.
      def escape( value )
        case value
          when nil then 'NULL'
          when String then Database.quote(value)
          else Database.quote(value.strftime('%H:%M:%S'))
        end
      end

      # Values are filtered by this function when being set.
      # Returns an instance of Time or nil if +value+ is nil or empty.
      def filter_set( value )
        case value
          when nil, '' then nil
          when ::Time then value
          when String then ::Time.parse( value )
          else raise Error
        end
       rescue => e
        raise ConversionError, 'Error while parsing time'
      end

    end
  end
end

