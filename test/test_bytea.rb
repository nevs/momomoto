
class TestBytea < Test::Unit::TestCase

  def test_escaping_null
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_bytea'
    data = ''
    data.concat 0
    data.concat "'"
    r = c.new
    r.data = data
    r.write
    r2 = c.select(:id=>r.id)
    assert_equal( 1, r2.length )
    assert_equal( data, r2[0].data )
  end

  def test_escaping_file
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_bytea'
    r = c.new
    data = File.new('test/bytea-test-file').read
    r.data = data
    assert_equal( data.length, r.data.length )
    assert_equal( data, r.data )
    r.write
    r2 = c.select(:id=>r.id)
    assert_equal( 1, r2.length )
    assert_equal( data.length , r2[0].data.length )
    assert_equal( data, r2[0].data )
  end

end


