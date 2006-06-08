
class TestDate < Test::Unit::TestCase

  def test_nil
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_date'
    r = c.new( :data => nil )
    assert_equal( nil, r.data )
    r.write
    r2 = c.select( :id => r.id ).first
    assert_equal( nil, r2.data )
  end

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_date'
    [ Date.parse("2005-5-23"), ::Date.today].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
    end
  end

  def test_string_conversion
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_date'
    [ "2005-5-23", "2006-06-06"].each do | value |
      r = c.new( :data => value )
      assert_equal( Date.parse( value ), r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( Date.parse( value ), r2.data )
    end
  end

  def test_invalid_dates
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_date'
    [ "2005-5-43", "2006-16-06"].each do | value |
      r = c.new
      assert_raise( Momomoto::Error ) do
        r.data = value
      end
    end
  end

end

