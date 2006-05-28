
class TestTimestampWithoutTimeZone < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Timestamp_without_time_zone.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_get( "2005-05-23 00:00:00" ) )
    assert_raise( Momomoto::Error ) do t.filter_get( Object.new ) end
    assert_raise( Momomoto::Error ) do t.filter_get( "abc" ) end
  end

  def test_filter_set
    t = Momomoto::Datatype::Timestamp_without_time_zone.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_set( "2005-05-23 00:00:00" ) )
    assert_raise( Momomoto::Error ) do t.filter_set( Object.new ) end
    assert_raise( Momomoto::Error ) do t.filter_set( "abc" ) end
  end

end

