
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestInteger < Test::Unit::TestCase

  def test_filter_set
    t = Momomoto::Datatype::Integer.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( 1, t.filter_set( 1 ) )
    assert_equal( 1, t.filter_set( '1' ) )
  end

  def test_filter_get
    t = Momomoto::Datatype::Integer.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( 1, t.filter_get( 1 ) )
    assert_equal( 1, t.filter_get( '1' ) )
  end

  def test_compile_rule
    t = Momomoto::Datatype::Integer.new
    assert_instance_of( String, t.compile_rule( :field, 1 ) )
    assert_instance_of( String, t.compile_rule( :field, [1] ) )
    assert_instance_of( String, t.compile_rule( :field, [1,2,3] ) )
    assert_instance_of( String, t.compile_rule( :field, { :eq => 1 } ) )
    assert_instance_of( String, t.compile_rule( :field, { :lt => 10, :gt => 5} ) )
  end

end

