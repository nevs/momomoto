
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestTable < Test::Unit::TestCase

  def setup
    @connection = Momomoto::Database.new('database'=>'pentabarf','username'=>'pentabarf')
  end

  def teardown
    @connection.disconnect
  end

  def test_base_initialize
    assert_raise( Momomoto::CriticalError ) { Momomoto::Base.new }
  end

end

