
class TestCharacter < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Character.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( "a", t.filter_get( "a" ) )
    assert_equal( "chunky bacon", t.filter_get( "chunky bacon" ) )
  end

  def test_filter_set
    t = Momomoto::Datatype::Character.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( "chunky bacon", t.filter_set( "chunky bacon" ) )
  end

end

