
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestTimeWithTimeZone < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Time_with_time_zone.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_get( "00:00:00" ) )
    assert_instance_of( DateTime, t.filter_get( "01:00:00" ) )
    assert_instance_of( DateTime, t.filter_get( "23:00:00" ) )
  end

  def test_filter_set
    t = Momomoto::Datatype::Time_with_time_zone.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_set( "00:00:00" ) )
    assert_instance_of( DateTime, t.filter_set( "01:00:00" ) )
    assert_instance_of( DateTime, t.filter_set( "23:00:00" ) )
  end

end

