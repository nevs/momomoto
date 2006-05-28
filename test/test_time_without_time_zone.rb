
class TestTimeWithoutTimeZone < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Time_without_time_zone.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( Time, t.filter_get( "00:00:00" ) )
    assert_instance_of( Time, t.filter_get( "01:00:00" ) )
    assert_instance_of( Time, t.filter_get( "23:00:00" ) )
    assert_raise( Momomoto::Error ) do t.filter_get( 123 ) end
  end

  def test_filter_set
    t = Momomoto::Datatype::Time_without_time_zone.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( Time, t.filter_set( "00:00:00" ) )
    assert_instance_of( Time, t.filter_set( "01:00:00" ) )
    assert_instance_of( Time, t.filter_set( "23:00:00" ) )
    assert_raise( Momomoto::Error ) do t.filter_set( 123 ) end
  end

end

