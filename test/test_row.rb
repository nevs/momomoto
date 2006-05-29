
class TestRow < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_table
    Momomoto::Information_schema::Columns.select(:table_schema => 'pg_catalog', :table_name => 'pg_tables')
    Momomoto::Information_schema::Key_column_usage.select(:table_schema => 'pg_catalog', :table_name => 'pg_class')
    assert_equal( Momomoto::Information_schema::Columns, Momomoto::Information_schema::Columns::Row.table )
    assert_equal( Momomoto::Information_schema::Key_column_usage, Momomoto::Information_schema::Key_column_usage::Row.table )
  end

  def test_inheritence
    self.class.const_set( :Person, Class.new( Momomoto::Table ) )
    Person.const_set( :Row, Class.new )
    assert_raise( Momomoto::CriticalError ) do Person.select end
  end

  def test_setter
    a = Class.new( Momomoto::Table )
    a.table_name = 'person'
    r = a.select_or_new( :person_id => 13 )
    r.write
    assert_raise( Momomoto::Error ) do r.person_id = 14 end
  end

end

