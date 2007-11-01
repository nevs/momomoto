
require 'date'

class TimeInterval

  include Comparable

  class ParseError < StandardError; end

  attr_reader :hour, :min, :sec

  class << self

    def parse( interval )
      TimeInterval.new( interval )
    end

  end

  def <=>( other )
    self.to_i <=> other.to_i
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
    case d
      when Hash then
        @hour = d[:hour] || 0
        @min = d[:min] || 0
        @sec = d[:sec] || 0
      when Integer then
        @hour = d/3600
        @min = (d/60)%60
        @sec = d%60
      when String then
        parsed = Date._parse( d, false)
        if ( parsed.empty? && d.length > 0 ) || !(parsed.keys - [:hour,:min,:sec,:sec_fraction]).empty?
          raise ParseError, "Could not parse interval `#{d}`"
        end
        @hour = parsed[:hour] || 0
        @min = parsed[:min] || 0
        @sec = parsed[:sec] || 0
    end
  end

end

