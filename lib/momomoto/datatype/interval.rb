module Momomoto
  module Datatype

    # This class represents the data type Interval.
    class Interval < Time_without_time_zone

      # Escapes +value+ before storing to database.
      # +value+ can be either 
      #   nil, resulting in 'NULL',
      #   String, which is escaped using Database#escape_string,
      #   or some escaped Date-like format
      def escape( value )
        case value
          when nil then 'NULL'
          when String then "'#{Database.escape_string(value)}'"
          else "'#{Database.escape_string(value.strftime('%H:%M:%S'))}'"
        end
      end
  
      # Values are filtered by this function when getting from database.
      # Returns an instance of TimeInterval or nil if +value+ is nil or
      # empty.
      def filter_get( value )
        case value
          when nil, '' then nil
          when ::TimeInterval then value
          when String then ::TimeInterval.parse( value )
          else raise Error
        end
       rescue => e
        raise ConversionError, "Error while parsing interval (#{e.message})"
      end

      # Values are filtered by this function when set.
      # See Interval#filter_get
      def filter_set( value )
        filter_get( value )
      end

    end
  end
end
