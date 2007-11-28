
module Momomoto

  # This module encapsulates all supporteed data types, i.e.:
  # Numeric, Integer, Bigint, Smallint, Real,
  # Timestamp_with_time_zone, Timestamp_without_time_zone,
  # Time_with_time_zone, Time_without_time_zone, Date, Interval,
  # Character, Character_varying, Bytea, Text, Inet and Boolean.
  #
  # Refer to http://www.postgresql.org/docs/8.2/static/datatype.html
  # for more information on the specific data types.
  #
  module Datatype

    # Every data type class (see #Datatype) is derived from this class.
    class Base

      # Gets the default value for this column or returns nil if none
      # exists.
      def default
        @default
      end

      # Returns true if this column can be NULL otherwise false
      def not_null?
        @not_null
      end

      # Creates a new instance of the special data type, setting +@not_null+
      # and +@default+ according to the values from Information Schema.
      def initialize( row = nil )
        @not_null = row.is_nullable == "NO" ? true : false
        @default = row.column_default
      end

      # Values are filtered by this function when being set. See the
      # method in the appropriate derived data type class for allowed
      # values.
      def filter_set( value ) # :nodoc:
        value
      end

      # Compares two values and return true if equal or false otherwise.
      # It is used to check if a row field has been changed so that only
      # changed fields are written to database.
      def equal( a, b )
        a == b
      end

      # Escapes +input+ to be saved in database.
      # If +input+ equals nil, NULL is returned, otherwise Database#escape_string
      # is called.
      # See the method in the appropriate derived data type class to know
      # how these are escaped.
      def escape( input )
        input.nil? ? "NULL" : "'" + Database.escape_string( input.to_s ) + "'"
      end

      # This function is used when compiling the where clause. No need
      # for direct use.
      def compile_rule( field_name, value ) # :nodoc:
        case value
          when nil then
            raise Error, "nil values not allowed for #{field_name}"
          when :NULL then
            field_name.to_s + ' IS NULL'
          when :NOT_NULL then
            field_name.to_s + ' IS NOT NULL'
          when Array then
            raise Error, "empty array conditions are not allowed for #{field_name}" if value.empty?
            raise Error, "nil values not allowed in compile_rule for #{field_name}" if value.member?( nil )
            field_name.to_s + ' IN (' + value.map{ | v | escape(filter_set(v)) }.join(',') + ')'
          when Hash then
            raise Error, "empty hash conditions are not allowed for #{field_name}" if value.empty?
            rules = []
            value.each do | op, v |
              raise Error, "nil values not allowed in compile_rule for #{field_name}" if v == nil
              v = [v] if not v.kind_of?( Array )
              if op == :eq # use IN if comparing for equality
                rules << compile_rule( field_name, v )
              else
                v.each do | v2 |
                  rules << field_name.to_s + ' ' + self.class.operator_sign(op) + ' ' + escape(filter_set(v2))
                end
              end
            end
            rules.join( " AND " )
          else
            field_name.to_s + ' = ' + escape(filter_set(value))
        end
      end

      # These are the operators supported by all data types. Note the
      # special case of instances of Text which can be also compared 
      # with the two operators +:like+ and +:ilike+.
      def self.operator_sign( op )
        case op
          when :le then '<='
          when :lt then '<'
          when :ge then '>='
          when :gt then '>'
          when :eq then '='
          when :ne then '<>'
          else
            raise CriticalError, "unsupported operator"
        end
      end

    end

  end
end

