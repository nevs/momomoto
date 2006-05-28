
class TestBoolean < Test::Unit::TestCase

  def test_filter_set
    row = Momomoto::Information_schema::Columns.new
    row.is_nullable = "YES"
    t = Momomoto::Datatype::Boolean.new( row )
    [nil,''].each do | input | assert_equal( nil, t.filter_set( input ) ) end
    [true,'t',1].each do | input | assert_equal( true, t.filter_set( input ) ) end
    [false,'f',0].each do | input | assert_equal( false, t.filter_set( input ) ) end
    row.is_nullable = "NO"
    t = Momomoto::Datatype::Boolean.new( row )
    [true,'t',1].each do | input | assert_equal( true, t.filter_set( input ) ) end
    [nil,'',false,'f',0].each do | input | assert_equal( false, t.filter_set( input ) ) end
  end

  def test_filter_get
    t = Momomoto::Datatype::Boolean.new
    [nil,''].each do | input | assert_equal( nil, t.filter_get( input ) ) end
    [true,'t',1].each do | input | assert_equal( true, t.filter_get( input ) ) end
    [false,'f',0].each do | input | assert_equal( false, t.filter_get( input ) ) end
  end

end

