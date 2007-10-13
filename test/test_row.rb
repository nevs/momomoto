
class TestRow < Test::Unit::TestCase

  class Person < Momomoto::Table; end

  def test_table
    Momomoto::Information_schema::Columns.select(:table_schema => 'pg_catalog', :table_name => 'pg_tables')
    Momomoto::Information_schema::Key_column_usage.select(:table_schema => 'pg_catalog', :table_name => 'pg_class')
    assert_equal( Momomoto::Information_schema::Columns, Momomoto::Information_schema::Columns::Row.table )
    assert_equal( Momomoto::Information_schema::Key_column_usage, Momomoto::Information_schema::Key_column_usage::Row.table )
  end

  def test_inheritence
    self.class.const_set( :Event, Class.new( Momomoto::Table ) )
    Event.const_set( :Row, Class.new )
    assert_raise( Momomoto::CriticalError ) do Event.select end
  end

  def test_setter
    a = Class.new( Momomoto::Table )
    a.table_name = 'person'
    r = a.select_or_new( :person_id => 13 )
    r.write
    assert_raise( Momomoto::Error ) do r.person_id = 14 end
  end

  def test_bracket
    a = Person.new
    assert_nil( a.person_id )
    assert_equal( a.person_id, a[:person_id])
    assert_equal( a.person_id, a['person_id'])
    a.person_id = 23
    assert_equal( 23, a.person_id)
    assert_equal( a.person_id, a[:person_id])
    assert_equal( a.person_id, a['person_id'])
    a[:person_id] = 42
    assert_equal( 42, a.person_id)
    assert_equal( a.person_id, a[:person_id])
    assert_equal( a.person_id, a['person_id'])
    a['person_id'] = 5
    assert_equal( 5, a.person_id)
    assert_equal( a.person_id, a[:person_id])
    assert_equal( a.person_id, a['person_id'])
  end

  def test_equal
    a = Person.new
    b = Person.new
    assert( a == b )
    assert( b == a )
    a.person_id = 23
    assert( a != b )
    assert( b != a )
    b.person_id = 23
    assert( a == b )
    assert( b == a )
  end

  def test_columns
    a = Person.new
    assert_equal( Person.columns, a.class.columns )
    assert_equal( Person.columns, Person::Row.columns )
  end

  def test_primary_key_setting
    a = Person.select_single( nil, {:limit=>1})
    assert_raise( Momomoto::Error ) do
      a.person_id = 42
    end
    assert_raise( Momomoto::Error ) do
      a.set_column( :person_id, 42 )
    end
  end

  def test_to_hash
    a = Person.new
    assert_instance_of( Hash, a.to_hash )
  end

end

