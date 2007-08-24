
class TestTable < Test::Unit::TestCase

  class Person < Momomoto::Table
    module Methods
      def nick_name=( newvalue )
        set_column(:nick_name, get_column(:first_name) + newvalue )
      end
    end
  end

  class Conference < Momomoto::Table
  end

  def test_default_order_getter
    c1 = Class.new( Momomoto::Table )
    c1.default_order = [:a,:b]
    assert_equal( [:a,:b], c1.default_order )
  end

  def test_default_order_setter
    c1 = Class.new( Momomoto::Table )
    c1.default_order = :a
    assert_equal( :a, c1.default_order )
    c1.default_order = :b
    assert_equal( :b, c1.default_order )
    c1.default_order( :c )
    assert_equal( :c, c1.default_order )
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
    p = Class.new( Momomoto::Table )
    p.table_name = 'person'
    p.schema_name = 'public'
    assert_nothing_raised do p.primary_keys end
  end

  def test_primary_key_setter
    a = Class.new( Momomoto::Table )
    a.primary_keys( [:pk] )
    assert_equal( [:pk], a.primary_keys )
    a.primary_keys= [:pk2]
    assert_equal( [:pk2], a.primary_keys )
  end

  def test_schema_name_getter
    self.class.const_set( :S, Class.new( Momomoto::Table ) )
    assert_equal( 'public', S.schema_name )
    S.schema_name = "chunky"
    assert_equal( "chunky", S.schema_name )
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
    assert_equal( 'public.abc', a.full_name )
    a.schema_name( 'def' )
    assert_equal( 'def.abc', a.full_name )
  end

  def test_custom_setter
    p = Person.new
    p.first_name = 'bacon'
    p.nick_name = 'abc'
    assert_equal( p.first_name + 'abc', p.nick_name )
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

  def test_offset
    p = Person.select( {}, {:limit => 1, :order => :person_id,:offset=>2})
    assert_operator( 2, :<, p[0].person_id )
    assert_raise( Momomoto::Error ) do 
      Person.select( {}, {:limit => 1, :order => :person_id,:offset=>'bacon'})
    end
  end

  def test_select_columns
    p = Person.select({},{:columns=>[:person_id,:first_name],:limit=>1})[0]
    assert( p.respond_to?( :person_id ))
    assert( p.respond_to?( :first_name ))
    assert_raise( NoMethodError ) do
      p.nick_name
    end
  end

  def test_select
    r = Person.select( nil, {:limit => 3})
    assert_equal( 3, r.length )
    Person.select( nil, {:limit => 3, :order => :person_id})
    Person.select( nil, {:limit => 3, :order => "person_id"})
    Person.select( nil, {:limit => 3, :order => ["person_id"]})
    Person.select( nil, {:limit => 3, :order => [:first_name, :last_name]} )
    Person.select( nil, {:limit => 3, :order => ['first_name', :last_name]} )
    Person.select( nil, {:limit => 3, :order => ['first_name', 'last_name']} )
    Person.select( nil, {:order => Momomoto::lower(:first_name)})
    Person.select( nil, {:order => Momomoto::lower(:first_name, :last_name)})
    Person.select( nil, {:order => Momomoto::asc( [:first_name, :last_name] )} )
    Person.select( nil, {:order => [:first_name, Momomoto::lower(:last_name )]} )
    Person.select( nil, {:order => [:first_name, Momomoto::desc(:last_name )]} )
    Person.select( nil, {:order => Momomoto::asc(Momomoto::lower(:first_name))})
    Person.select( nil, {:order => Momomoto::desc(Momomoto::lower(:first_name))})
    assert_raise( Momomoto::Error ) do
      Person.select( nil, {:order => Momomoto::lower(Momomoto::asc(:first_name))})
    end
    assert_raise( Momomoto::Error ) do
      Person.select( nil, {:order => Momomoto::lower(Momomoto::desc(:first_name))})
    end
    assert_raise( Momomoto::Error ) do
      Person.select( nil, {:limit=>'4f4'} )
    end
    assert_raise( Momomoto::Error ) do
      Person.select( nil, {:order=>:chunky})
    end
    assert_raise( Momomoto::Error ) do
      Person.select( nil, {:order=>[:chunky,:bacon]})
    end
    assert_raise( Momomoto::Error ) do
      Person.select( nil, {:order=>Object.new})
    end
    assert_raise( Momomoto::Error ) do
      Person.select( nil, {:order=>[Object.new, Object.new]})
    end
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

  def test_select_single
    # delete existing test_select_single entries
    Person.select(:first_name=>'test_select_single').each do | p | p.delete end

    assert_raise( Momomoto::Nothing_found ) do
      Person.select_single(:first_name=>'test_select_single')
    end

    p1 = Person.new(:first_name=>'test_select_single')
    p1.write
    p2 = Person.new(:first_name=>'test_select_single')
    p2.write

    assert_raise( Momomoto::Too_many_records ) do
      Person.select_single(:first_name=>'test_select_single')
    end
    p1.delete
    p2.delete
  end

  def test_update
    Person.select(:first_name=>'test_update').each do | p | p.delete end

    assert_raise( Momomoto::Nothing_found ) do
      Person.select_single(:first_name=>'test_update')
    end

    p1 = Person.new(:first_name=>'test_select_single')
    p1.write
    p1.first_name = 'Chunky'
    p1.last_name = 'Bacon'
    p1.write
    p2 = Person.select_single(:person_id=>p1.person_id)
    assert_equal( p1.person_id, p2.person_id)
    assert_equal( p1.first_name, p2.first_name )
    assert_equal( p1.last_name, p2.last_name)

    p1.delete
  end

  def test_defaults
    conf = Conference.select_or_new(:conference_id=>1)
    conf.acronym = 'Pentabarf'
    conf.title = 'Pentabarf Developer Conference'
    conf.start_date = '2007-08-07'
    conf.write
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

  def test_write2
    self.class.const_set(:Test_nodefault, Class.new( Momomoto::Table ) )
    Test_nodefault.schema_name = nil
    a = Test_nodefault.new
    a.data = 'chunky bacon'
    assert_equal( [:id], Test_nodefault.primary_keys )
    assert_raise( Momomoto::Error ) do
      a.write
    end
  end

  def test_dirty
    r = Person.new
    assert_equal( false, r.dirty?, "New empty rows should not be dirty" )
    r.first_name = 'Chunky'
    assert_equal( true, r.dirty?, "Modified rows must be dirty" )
    r.write
    assert_equal( false, r.dirty?, "Written rows should not be dirty" )
    r.delete
    r = Person.new(:first_name => 'Chunky')
    assert_equal( true, r.dirty? )
  end

end

