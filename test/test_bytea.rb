
class TestBytea < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Bytea.new
    assert_equal( "\n", t.filter_get( '\012' ) )
  end

end


