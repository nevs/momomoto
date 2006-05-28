
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestDatabase < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.config('database'=>'pentabarf','username'=>'pentabarf')
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_begin
    db = Momomoto::Database.instance
    assert_nothing_raised do db.begin end
  end

  def test_rollback
    db = Momomoto::Database.instance
    db.begin
    assert_nothing_raised do db.rollback end
    assert_raise( Momomoto::Error ) do db.rollback end
  end

  def test_commit
    db = Momomoto::Database.instance
    db.begin
    assert_nothing_raised do db.commit end
    assert_raise( Momomoto::Error ) do db.commit end
  end

end

