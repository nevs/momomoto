
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

  def test_filter_set
    t = Momomoto::Datatype::Bytea.new
    

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

  def test_escaping2
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_bytea'
    r = c.new
    data = File.new('test/bytea-test-file').read
    r.data = data
    r.data.length
    r2 = c.select(:id=>r.id)
    assert_equal( 1, r2.length )
    assert_equal( data, r2.data )
  end

end


