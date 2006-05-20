
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestBase < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_base_initialize
    assert_raise( Momomoto::CriticalError ) { Momomoto::Base.new }
  end

  def test_class_variable_set
    TestBase.const_set( :CVST, Class.new( Momomoto::Base ) )
    CVST.send(:define_method, :initialize) do end
    a = CVST.new
    assert_raise( NameError ) do a.class.send( :class_variable_get,  :@@sven ) end
    a.class_variable_set( :@@sven, true )
    assert_equal( true, a.class.send( :class_variable_get, :@@sven ) )
  end

end

