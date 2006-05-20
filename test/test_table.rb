
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

module Schema1; end

module Schema1::Schema2; end

class SchemaNameGetter1 < Momomoto::Table; end

class Schema1::SchemaNameGetter2 < Momomoto::Table; end

class Schema1::Schema2::SchemaNameGetter3 < Momomoto::Table; end

class SchemaNameGetter4 < Momomoto::Table
  schema_name( 'schema4' )
end

class SchemaNameGetter5 < Momomoto::Table
  self.schema_name=( 'schema5' )
end

class SchemaNameSetter1 < Momomoto::Table; end

class SchemaNameSetter2 < Momomoto::Table
  schema_name( 'schema2' )
end

class ColumnsGetter1 < Momomoto::Table; end
class ColumnsGetter2 < Momomoto::Table
  self.columns=( {:a => Momomoto::Datatype::Text} )
end
class ColumnsGetter3 < Momomoto::Table
  columns( {:b => Momomoto::Datatype::Text})
end

class ColumnsSetter1 < Momomoto::Table; end
class ColumnsSetter2 < Momomoto::Table
  columns( {:b => Momomoto::Datatype::Text})
end

class Person < Momomoto::Table
end

class TableNameGetter1 < Momomoto::Table; end

class TableNameGetter2 < Momomoto::Table
  self.table_name=( 'name2')
end

class TableNameGetter3 < Momomoto::Table
  table_name( 'name3' )
end

class TableNameSetter1 < Momomoto::Table; end

class TableNameSetter2 < Momomoto::Table
  table_name( 'name2' )
end

class TestTable < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.config('database'=>'pentabarf','username'=>'pentabarf')
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_table_initialize
    assert_raise( Momomoto::CriticalError ) { Momomoto::Table.new }
  end

  def test_columns_getter
    assert_nil( ColumnsGetter1.columns, 'Checking columns getter' )
    assert_equal( {:a=>Momomoto::Datatype::Text}, ColumnsGetter2.columns, 'Checking columns getter' )
    assert_equal( {:b=>Momomoto::Datatype::Text}, ColumnsGetter3.columns, 'Checking columns getter' )
  end

  def test_columns_setter
    ColumnsSetter1.columns = {:a => Momomoto::Datatype::Text}
    assert_equal( {:a=>Momomoto::Datatype::Text}, ColumnsSetter1.columns, 'Checking columns getter' )
    assert_equal( {:b=>Momomoto::Datatype::Text}, ColumnsSetter2.columns, 'Checking columns getter' )
    ColumnsSetter2.columns = {:c => Momomoto::Datatype::Text}
    assert_equal( {:a=>Momomoto::Datatype::Text}, ColumnsSetter1.columns, 'Checking columns getter' )
    assert_equal( {:c=>Momomoto::Datatype::Text}, ColumnsSetter2.columns, 'Checking columns getter' )
  end

  def test_primary_key_getter
    a = Person.new
    assert_equal([:person_id], Person.primary_keys())
  end

  def test_primary_key_getter
    Person.send( :primary_keys=, [:key_id] )
    assert_equal([:key_id], Person.primary_keys())
  end

  def test_schema_name_getter
    assert_equal( nil, SchemaNameGetter1.schema_name, 'Checking schema getter' )
    assert_equal( 'schema1', Schema1::SchemaNameGetter2.schema_name )
    assert_equal( 'schema2', Schema1::Schema2::SchemaNameGetter3.schema_name )
    assert_equal( 'schema4', SchemaNameGetter4.schema_name )
    assert_equal( 'schema5', SchemaNameGetter5.schema_name )
  end

  def test_schema_name_setter
    SchemaNameSetter1.schema_name = 'schema1'
    assert_equal( 'schema1', SchemaNameSetter1.schema_name )
    assert_equal( 'schema2', SchemaNameSetter2.schema_name )
    SchemaNameSetter2.schema_name = 'schema3'
    assert_equal( 'schema1', SchemaNameSetter1.schema_name )
    assert_equal( 'schema3', SchemaNameSetter2.schema_name )
  end

  def test_table_name_getter
    assert_equal('tablenamegetter1', TableNameGetter1.table_name, 'Checking table_name getter of unitialized class.' )
    assert_equal('name2', TableNameGetter2.table_name, 'Checking table_name getter of unitialized class.' )
    assert_equal('name3', TableNameGetter3.table_name, 'Checking table_name getter of unitialized class.' )
  end

  def test_table_name_setter
    TableNameSetter1.table_name = 'name1'
    assert_equal('name1', TableNameSetter1.table_name, 'Checking table_name setter.' )
    assert_equal('name2', TableNameSetter2.table_name, 'Checking for side effects of table_name setter.' )
    TableNameSetter2.table_name = 'name3'
    assert_equal('name1', TableNameSetter1.table_name, 'Checking table_name setter.' )
    assert_equal('name3', TableNameSetter2.table_name, 'Checking table_name setter.' )
  end

  def test_create
    anonymous = Person.create
    assert_equal(Person::Row, anonymous.class)
    assert_equal( true, anonymous.new_record? )
    assert_nil( anonymous.first_name )
    sven = Person.create(:login_name=>'sven', :first_name=>'Sven',:last_name=>'Klemm')
    assert_equal( 'sven', sven.login_name )
    assert_equal( 'Sven', sven.first_name )
    assert_equal( true, sven.new_record? )
  end

end

