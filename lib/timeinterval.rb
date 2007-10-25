
require 'date'

class TimeInterval

  class ParseError < StandardError; end

  attr_reader :hour, :min, :sec

  class << self

    def parse( interval )
      d = Date._parse( interval, false)
      if d.empty? && interval.length > 0
        raise ParseError, "Could not parse interval `#{interval}`"
      end
      if !(d.keys - [:hour,:min,:sec]).empty?
        raise ParseError, "Could not parse interval `#{interval}`"
      end
      TimeInterval.new( d )
    end

  end

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

  def to_i
    @hour * 3600 + @min * 60 + @sec
  end

  alias_method :to_int, :to_i

  def to_s
    strftime
  end

  def initialize( d = {} )
    @hour = d[:hour] || 0
    @min = d[:min] || 0
    @sec = d[:sec] || 0
  end

end

