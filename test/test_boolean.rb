
class TestBoolean < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_boolean'
    [nil,true,false].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
    end
    r = c.new
    [nil,''].each do | input |
      r.data = input
      assert_equal( nil, r.data )
    end
    [true,'t',1].each do | input |
      r.data = input
      assert_equal( true, r.data )
    end
    [false,'f',0].each do | input |
      r.data = input
      assert_equal( false, r.data )
    end
  end

end

