
class TestTimeWithoutTimeZone < Test::Unit::TestCase

  def test_invalid
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_time_without_time_zone'
    [ :x, 2.3 ].each do | value |
      r = c.new
      assert_raise( Momomoto::Error ) do
        r.data = value
      end
    end
  end

  def test_string_conversion
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_time_without_time_zone'
    [ "20:00:00", "23:42"].each do | value |
      r = c.new( :data => value )
      assert_equal( Time.parse( value ), r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( Time.parse( value ), r2.data )
    end
  end

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_time_without_time_zone'
    [Time.parse("00:00:00"),Time.parse("01:00:00"),Time.parse("23:00")].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
    end
  end

end

