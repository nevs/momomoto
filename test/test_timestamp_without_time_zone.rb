
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestTimestampWithoutTimeZone < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Timestamp_without_time_zone.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_get( "2005-05-23 00:00:00" ) )
  end

  def test_filter_set
    t = Momomoto::Datatype::Timestamp_without_time_zone.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_get( "2005-05-23 00:00:00" ) )
  end

end

