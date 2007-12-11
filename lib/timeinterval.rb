
require 'date'

# The class is used in Momomoto to represent the SQL interval datatype
class TimeInterval

  include Comparable

  # Is raised if a String containing some representation of date cannot
  # be parsed
  #
  #     TimeInterval.new( {:hour => '42', :min => '23'} )
  #       => #<TimeInterval:0x505c565c @hour="42", @sec=0, @min="23">
  #     TimeInterval.new('invalid')
  #       => TimeInterval::ParseError: Could not parse interval 'invalid'
  #
  class ParseError < StandardError; end

  # Getter methods for hours, minutes and seconds
  #
  #   interval = TimeInterval.new( {:hour => 42, :min => 23} )
  #     time.hour => 42
  #     time.min => 23
  #     time.sec => 0
  #
  attr_reader :hour, :min, :sec

  class << self

    # Converts the given +interval+ and returns the correspondind
    # TimeInterval instane.
    #   interval = TimeInterval.new( "00:23" )
    def parse( interval )
      TimeInterval.new( interval )
    end

  end

  # Compares two TimeInterval instances by converting into seconds and
  # applying #<=> to them.
  # Returns 1 (first > last), 0 (first == last) or -1 (first < last).
  #
  #   i1 = TimeInterval.new( {:hour => 42, :min => 23, :sec => 2} )
  #     i1.to_i => 152582
  #   i2 = TimeInterval.new( {:hour => 5, :min => 23, :sec => 2} )
  #     i2.to_i => 19382
  #
  #   i1 <=> i2 => 1
  #
  def <=>( other )
    self.to_i <=> other.to_i
  end

  # add something to a TimeInterval instance
  def +( other )
    self.class.new( self.to_i + other.to_i )
  end

  # subtract something to a TimeInterval instance
  def -( other )
    self.class.new( self.to_i - other.to_i )
  end

  # Formats timeinterval according to the directives in the given format
  # string.
  #   i = TimeInterval.new(2342)
  #
  #   i.strftime( "%H" )  => "00"
  #   i.strftime( "%M" )  => "39"
  #   i.strftime( "%S" )  => "02"
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

  # Returns the value of timeinterval as number of seconds
  def to_i
    @hour * 3600 + @min * 60 + @sec
  end

  alias_method :to_int, :to_i

  # Returns the value of timeinterval as number of seconds
  def to_f
    self.to_i.to_f
  end

  # Returns a string representing timeinterval. Equivalent to calling
  # Time#strftime with a format string of '%H:%M:%S'.
  #
  #   i.inspect  => "#<TimeInterval:0x517e36b8 @hour=0, @sec=2, @min=39>"
  #   i.to_s     => "00:39:02"
  #   i.strftime  => "00:39:02"
  def to_s
    strftime( '%H:%M:%S' )
  end

  # Creates a new instance of TimeInterval with +d+ representing either
  # a value of type #Hash
  #
  #   TimeInterval.new( {:hour => 5}),
  #
  # a value of type #Integer in seconds
  #
  #   TimeInterval.new( 23 ),
  #
  # or of type #String
  #
  #   TimeInterval.new( "00:23" ).
  #
  # Use getter methods #hour, #min and #sec in your code.
  def initialize( d = {} )
    case d
      when Hash then
        init_from_hash( d )
      when Integer then
        init_from_int( d )
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

  def init_from_int( d )
    @hour = d/3600
    @min = (d/60)%60
    @sec = d%60
  end

end

