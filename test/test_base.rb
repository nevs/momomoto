
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

end

