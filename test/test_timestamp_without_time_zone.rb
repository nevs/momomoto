
class TestTimestampWithoutTimeZone < Test::Unit::TestCase

  def test_invalid
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_timestamp_without_time_zone'
    [ :x, 2.3 ].each do | value |
      r = c.new
      assert_raise( Momomoto::Error ) do
        r.data = value
      end
    end
  end

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_timestamp_without_time_zone'
    [Time.parse("2005-05-23 00:00:00")].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
    end
  end

end

