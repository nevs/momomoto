
class TestInterval < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Inet.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( nil, t.filter_get( '' ) )
    assert_equal( "127.0.0.1", t.filter_get( '127.0.0.1' ) )
  end

  def test_filter_set
    t = Momomoto::Datatype::Inet.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_equal( "127.0.0.1", t.filter_set( '127.0.0.1' ) )
  end

end

