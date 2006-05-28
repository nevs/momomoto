
class TestNumeric < Test::Unit::TestCase

  def test_filter_set
    t = Momomoto::Datatype::Numeric.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( 1.0, t.filter_set( 1 ) )
    assert_equal( 1.0, t.filter_set( '1' ) )
  end

  def test_filter_get
    t = Momomoto::Datatype::Numeric.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( 1.0, t.filter_get( 1 ) )
    assert_equal( 1.0, t.filter_get( '1' ) )
  end

end

