
class TestBigint < Test::Unit::TestCase

  def test_filter_set
    t = Momomoto::Datatype::Bigint.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( 1, t.filter_set( 1 ) )
    assert_equal( 1, t.filter_set( '1' ) )
  end

end

