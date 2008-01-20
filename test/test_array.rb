
class TestArray < Test::Unit::TestCase

  def test_int_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_int_array'
    [[1,2,3],nil,[],[1]].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
      r.delete
    end
  end

  def test_text_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_text_array'
    [['chunky','bacon'],nil,[],['foo']].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
      r.delete
    end
  end

  def test_escape
    a = Momomoto::Datatype::Array.new
    assert_equal( a.escape( '{1,2,3}' ), "'{1,2,3}'" )
  end

  def test_filter_get_text
    a = Momomoto::Datatype::Array::Text.new
    assert_equal( a.filter_get( '{1,2,3}' ), ['1','2','3'] )
    assert_equal( a.filter_get( "{',bacon,chunky}" ), ["'","bacon","chunky"] )
    assert_equal( a.filter_get( '{",",bacon,chunky}' ), [",","bacon","chunky"] )
    assert_raise( Momomoto::Error ) do
      a.filter_get( "{\"}")
    end
  end

  def test_filter_get_integer
    a = Momomoto::Datatype::Array::Integer.new
    assert_equal( a.filter_get( '{1,2,3}' ), [1,2,3] )
  end

end

