
module Momomoto
  module Datatype
    # base class for all datatypes
    class Base
      attr_reader :default

      # is this column a not null column
      def not_null?
        @not_null
      end

      # is this column a primary key
      def primary_key?
        @primary_key
      end

      def initialize( row = nil )
        @not_null = row.respond_to?(:is_nullable) && row.is_nullable == "NO"
        @default = row.respond_to?(:column_default) && row.column_default
        @primary_key = false
      end
      
      def filter_set( value )
        value.nil? ? nil : value.to_s.gsub('\\', '')
      end

      def filter_get( value )
        value
      end

      def self.escape( input )
        input.nil? ? "NULL" : "'" + PGconn.escape( input.to_s ) + "'"
      end

      def escape( input )
        self.class.escape( input )
      end
    
    end

    class Bigint < Base; end
    class Boolean < Base; end
    class Bytea < Base; end
    class Character < Base; end
    class Character_varying < Base; end
    class Date < Base; end
    class Inet < Base; end
    class Integer < Base; end
    class Interval < Base; end
    class Numeric < Base; end
    class Real < Base; end
    class Smallint < Base; end
    class Text < Base; end
    class Time_with_time_zone < Base; end
    class Time_without_time_zone < Base; end
    class Timestamp_with_time_zone < Base; end
    class Timestamp_without_time_zone < Base; end

  end
end

