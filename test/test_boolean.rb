
class TestBoolean < Test::Unit::TestCase

  def test_filter_set
    row = Momomoto::Information_schema::Columns.create
    row.is_nullable = "YES"
    t = Momomoto::Datatype::Boolean.new( row )
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_equal( true, t.filter_set( true ) )
    assert_equal( true, t.filter_set( 't' ) )
    assert_equal( true, t.filter_set( 1 ) )
    assert_equal( false, t.filter_set( false ) )
    assert_equal( false, t.filter_set( 'f' ) )
    assert_equal( false, t.filter_set( 0 ) )
    row.is_nullable = "NO"
    t = Momomoto::Datatype::Boolean.new( row )
    assert_equal( false, t.filter_set( nil ) )
    assert_equal( false, t.filter_set( '' ) )
    assert_equal( true, t.filter_set( true ) )
    assert_equal( true, t.filter_set( 't' ) )
    assert_equal( true, t.filter_set( 1 ) )
    assert_equal( false, t.filter_set( false ) )
    assert_equal( false, t.filter_set( 'f' ) )
    assert_equal( false, t.filter_set( 0 ) )
  end

end

