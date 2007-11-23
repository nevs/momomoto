
require 'date'

# the class is used in Momomoto to represent the SQL interval datatype
class TimeInterval

  include Comparable

  class ParseError < StandardError; end

  attr_reader :hour, :min, :sec

  class << self

    def parse( interval )
      TimeInterval.new( interval )
    end

  end

  # compare two TimeInterval instances
  # the comparison is done by calling to_i on other
  def <=>( other )
    self.to_i <=> other.to_i
  end

  # formats timeinterval according to the directives in the give format
  # string
  def strftime( fmt = "%H:%M:%S" )
    fmt.gsub( /%(.)/ ) do | match |
      case match[1,1]
        when 'H' then sprintf('%02d',@hour)
        when 'M' then sprintf('%02d',@min)
        when 'S' then sprintf('%02d',@sec)
        when '%' then '%'
        else match
      end
    end
  end

  # returns the value of timeinterval as number of seconds
  def to_i
    @hour * 3600 + @min * 60 + @sec
  end

  alias_method :to_int, :to_i

  # Returns a string representing timeinterval. Equivalent to calling
  # Time#strftime with a format string of '%H:%M:%S'.
  def to_s
    strftime( '%H:%M:%S' )
  end

  def initialize( d = {} )
    case d
      when Hash then
        init_from_hash( d )
      when Integer then
        @hour = d/3600
        @min = (d/60)%60
        @sec = d%60
      when String then
        parsed = Date._parse( d, false)
        if ( parsed.empty? && d.length > 0 ) || !(parsed.keys - [:hour,:min,:sec,:sec_fraction]).empty?
          raise ParseError, "Could not parse interval `#{d}`"
        end
        init_from_hash( parsed )
    end
  end

  protected

  def init_from_hash( d )
    @hour = Integer( d[:hour] || 0 )
    @min = Integer( d[:min] || 0 )
    @sec = Integer( d[:sec] || 0 )
  end

end

