
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class TestInformationSchema < Test::Unit::TestCase

  def setup
    @connection = Momomoto::Database.new('database'=>'pentabarf','username'=>'pentabarf')
  end

  def teardown
    @connection.disconnect
  end

  # test for working information_schema.columns class
  def test_information_schema_columns
    a = Momomoto::Information_schema::Columns.select(:table_schema => 'pg_catalog', :table_name => 'pg_tables')
    assert_operator( 0, :<, a.length )
  end

  # test for working information_schema.key_column_usage class
  def test_information_schema_key_column_usage
    a = Momomoto::Information_schema::Key_column_usage.select(:table_schema => 'pg_catalog', :table_name => 'pg_class')
    assert_equal( 0, a.length )
    a = Momomoto::Information_schema::Key_column_usage.select(:table_schema => 'public')
    assert_operator( 0, :<, a.length )
  end

  # test for working information_schema.table_constraints class
  def test_information_schema_table_constraints
    a = Momomoto::Information_schema::Table_constraints.select(:table_schema => 'pg_catalog', :table_name => 'pg_class')
    assert_equal( 0, a.length )
    a = Momomoto::Information_schema::Table_constraints.select(:table_schema => 'public')
    assert_operator( 0, :<, a.length )
  end

end

