
class TestBytea < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_filter_get
    t = Momomoto::Datatype::Bytea.new
    assert_equal( "\n", t.filter_get( '\012' ) )
  end

  def test_escaping
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_bytea'
    r = c.select_or_new({:id=>1})
    r.data = "\n"
    assert_equal( "\n", r.data )
    r.write
    r = c.select(:id=>1).first
    assert_equal( "\n", r.data )
    r.delete
  end

end


