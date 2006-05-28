
class TestDate < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Date.new
    today = Date.today
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( today, t.filter_get( today ) )
    assert_instance_of( Date, t.filter_get( "2005-5-23" ) )
    assert_raise( Momomoto::Error ) do t.filter_get( "2005-05" ) end
    assert_raise( Momomoto::Error ) do t.filter_get( Object.new ) end
  end

  def test_filter_set
    t = Momomoto::Datatype::Date.new
    today = Date.today
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( today, t.filter_set( today ) )
    assert_instance_of( Date, t.filter_set( "2005-5-23" ) )
    assert_raise( Momomoto::Error ) do t.filter_set( "2005-05" ) end
    assert_raise( Momomoto::Error ) do t.filter_set( Object.new ) end
  end

end

