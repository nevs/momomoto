
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
    a = Class.new( Momomoto::Table )
    b = Class.new( Momomoto::Table )
    a.schema_name = :chunky
    b.schema_name = :bacon
    assert_equal( :chunky, a.schema_name )
    assert_equal( :bacon, b.schema_name )
    a.schema_name( :ratbert )
    assert_equal( :ratbert, a.schema_name )
    assert_equal( :bacon, b.schema_name )
  end

  def test_table_name_getter
    t = Class.new( Momomoto::Table )
    t.table_name = "chunky"
    assert_equal( "chunky", t.table_name )
  end

  def test_table_name_setter
    t = Class.new( Momomoto::Table )
    t.table_name = "chunky"
    assert_equal( "chunky", t.table_name )
    t.table_name = "bacon"
    assert_equal( "bacon", t.table_name )
    t.table_name( "fox" )
    assert_equal( "fox", t.table_name )
  end

  def test_full_name
    a = Class.new( Momomoto::Table )
    a.table_name( 'abc' )
    assert_equal( 'abc', a.full_name )
    a.schema_name( 'def' )
    assert_equal( 'def.abc', a.full_name )
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
    r2 = Person.select_or_new do | field_name |
      assert( Person.columns.keys.member?( field_name ))
      r.send( field_name )
    end
    r2.write
    assert_equal( 1, Person.select(:person_id => 7).length )
    r2.delete
    assert_equal( 0, Person.select(:person_id => 7).length )
  end

  def test_write
    r = Person.new
    r.first_name = 'Chunky'
    r.last_name = 'Bacon'
    r.write
    assert_not_nil( r.person_id )
    assert_nothing_raised do
      r.delete
      r.write
      r.delete
    end
  end

end

