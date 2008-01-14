
require 'date'

module Momomoto
  module Datatype

    # Represents the data type Timestamp without time zone.
    class Timestamp_without_time_zone < Base

      # Escapes +value+ to be saved in database.
      def escape( value )
        case value
          when nil then 'NULL'
          when String then Database.quote(value)
          else Database.quote(value.strftime('%Y-%m-%d %H:%M:%S'))
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
        raise ConversionError, "Error while parsing Timestamp"
      end

    end
  end
end
