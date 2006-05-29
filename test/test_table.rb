
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
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_columns_getter
    c1 = Class.new( Momomoto::Table )
    c1.columns =  {:a=>Momomoto::Datatype::Text}
    assert_equal( {:a=>Momomoto::Datatype::Text}, c1.columns )
  end

  def test_columns_setter
    c1 = Class.new( Momomoto::Table )
    c1.columns =  {:a=>Momomoto::Datatype::Text}
    assert_equal( {:a=>Momomoto::Datatype::Text}, c1.columns )
    c1.columns =  {:b=>Momomoto::Datatype::Text}
    assert_equal( {:b=>Momomoto::Datatype::Text}, c1.columns )
    c1.columns({:c=>Momomoto::Datatype::Text})
    assert_equal( {:c=>Momomoto::Datatype::Text}, c1.columns )
  end

  def test_primary_key_getter
    a = Class.new( Momomoto::Table )
    a.primary_keys( [:pk] )
    assert_equal( [:pk], a.primary_keys )
    self.class.const_set( :Person, Class.new( Momomoto::Table ) )
    Person.schema_name = nil
    assert_nothing_raised do Person.primary_keys end
  end

  def test_primary_key_setter
    a = Class.new( Momomoto::Table )
    a.primary_keys( [:pk] )
    assert_equal( [:pk], a.primary_keys )
    a.primary_keys= [:pk2]
    assert_equal( [:pk2], a.primary_keys )
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

  def test_full_name
    a = Class.new( Momomoto::Table )
    a.table_name( 'abc' )
    assert_equal( 'abc', a.full_name )
    a.schema_name( 'def' )
    assert_equal( 'def.abc', a.full_name )
  end

  def test_table_name_setter
    TableNameSetter1.table_name = 'name1'
    assert_equal('name1', TableNameSetter1.table_name, 'Checking table_name setter.' )
    assert_equal('name2', TableNameSetter2.table_name, 'Checking for side effects of table_name setter.' )
    TableNameSetter2.table_name = 'name3'
    assert_equal('name1', TableNameSetter1.table_name, 'Checking table_name setter.' )
    assert_equal('name3', TableNameSetter2.table_name, 'Checking table_name setter.' )
  end

  def test_new
    anonymous = Person.new
    assert_equal(Person::Row, anonymous.class)
    assert_equal( true, anonymous.new_record? )
    assert_nil( anonymous.first_name )
    sven = Person.new(:first_name=>'Sven',:last_name=>'Klemm')
    assert_equal( 'Klemm', sven.last_name )
    assert_equal( 'Sven', sven.first_name )
    assert_equal( true, sven.new_record? )
  end

  def test_select_or_new
    r = Person.select_or_new({:person_id => 7})
    r.first_name = 'Sven'
    r.write
    assert_equal( 1, Person.select(:person_id => 7).length )
    r.delete
    assert_equal( 0, Person.select(:person_id => 7).length )
    r = Person.select_or_new({:person_id => 7})
    assert_instance_of( Person::Row, r )
  end



end

