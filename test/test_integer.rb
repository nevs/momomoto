
class TestInteger < Test::Unit::TestCase

  def test_filter_set
    t = Momomoto::Datatype::Integer.new
    assert_equal( 1, t.filter_set( 1 ) )
    assert_equal( 1, t.filter_set( '1' ) )
  end

end

