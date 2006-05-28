
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestTimestampWithTimeZone < Test::Unit::TestCase

  def test_filter_get
    t = Momomoto::Datatype::Timestamp_with_time_zone.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_get( "2005-05-23 00:00:00 +0200" ) )
    assert_raise( Momomoto::Error ) do t.filter_get( Object.new ) end
    assert_raise( Momomoto::Error ) do t.filter_get( "abc" ) end
  end

  def test_filter_set
    t = Momomoto::Datatype::Timestamp_with_time_zone.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( nil, t.filter_set( '' ) )
    assert_instance_of( DateTime, t.filter_get( "2005-05-23 00:00:00 +0200" ) )
    assert_raise( Momomoto::Error ) do t.filter_set( Object.new ) end
    assert_raise( Momomoto::Error ) do t.filter_set( "abc" ) end
  end

end

