
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

end

