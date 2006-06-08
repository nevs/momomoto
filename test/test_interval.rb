
class TestInterval < Test::Unit::TestCase

  def test_nil
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_interval'
    r = c.new( :data => nil )
    assert_equal( nil, r.data )
    r.write
    r2 = c.select( :id => r.id ).first
    assert_equal( nil, r2.data )
  end

  def test_invalid
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_interval'
    [ :x, 2.3 ].each do | value |
      r = c.new
      assert_raise( Momomoto::Error ) do
        r.data = value
      end
    end
  end

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_interval'
    [Time.parse("00:00:00"), Time.parse("01:00:00"), Time.parse("23:00:00")].each do | number |
      r = c.new( :data => number )
      assert_equal( number, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( number, r2.data )
    end
  end

end

