
class TestDatabase < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_begin
    db = Momomoto::Database.instance
    assert_nothing_raised do db.begin end
  end

  def test_commit
    db = Momomoto::Database.instance
    db.begin
    assert_nothing_raised do db.commit end
    assert_raise( Momomoto::Error ) do db.commit end
  end

  def test_connect
    db = Momomoto::Database.instance
    db.disconnect
    old_config = db.send( :instance_variable_get, :@config )
    db.config( :port => 65535 )
    assert_raise( Momomoto::CriticalError ) do
      db.connect
    end
    db.config( old_config )
    db.connect
  end

  def test_execute
    db = Momomoto::Database.instance
    db.execute("SELECT version();")
    assert_raise( Momomoto::CriticalError ) do
      db.execute( "chunky bacon;")
    end
  end

  def test_rollback
    db = Momomoto::Database.instance
    db.begin
    assert_nothing_raised do db.rollback end
    assert_raise( Momomoto::Error ) do db.rollback end
  end

  def test_transaction
    db = Momomoto::Database.instance
    assert_nothing_raised do 
      db.transaction do end
    end
    assert_raise( Momomoto::CriticalError ) do
      db.transaction do
        db.execute( "chunky bacon;")
      end
    end

  end

end

