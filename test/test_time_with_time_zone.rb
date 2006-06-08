
class TestTimeWithTimeZone < Test::Unit::TestCase

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_time_with_time_zone'
    [Time.parse("00:00:00"),Time.parse("01:00:00"),Time.parse("23:00")].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
    end
  end

end

