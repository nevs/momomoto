
class TestProcedure < Test::Unit::TestCase

  def test_sql_function_parameter
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_sql")
    assert_equal( 1, a.parameters.length )
    assert_equal( [:param1], a.parameters[0].keys )
  end

  def test_plpqsql_function_parameter
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_plpgsql")
    assert_equal( 2, a.parameters.length )
    assert_equal( [:param1], a.parameters[0].keys )
    assert_equal( [:param2], a.parameters[1].keys )
  end

  def test_procedure_name
    self.class.const_set( :Proc1, Class.new( Momomoto::Procedure ) )
    assert_equal( 'proc1', Proc1.procedure_name )
    self.class.const_set( :Proc2, Class.new( Momomoto::Procedure ) )
    assert_equal( 'proc2', Proc2.procedure_name )
    Proc2.procedure_name( 'proc3' )
    assert_equal( 'proc3', Proc2.procedure_name )
    Proc2.procedure_name = 'proc4'
    assert_equal( 'proc4', Proc2.procedure_name )
    assert_equal( 'proc1', Proc1.procedure_name )
  end

  def test_columns_fetching
    p = Class.new( Momomoto::Procedure )
    p.procedure_name = 'fetch_procedure_columns'
    p.schema_name = 'momomoto'
    assert_equal( 2, p.columns.length )
  end

  def test_columns
    p = Class.new( Momomoto::Procedure )
    p2 = Class.new( Momomoto::Procedure )
    p.columns = :chunky
    p2.columns = :alice
    assert_equal( :chunky, p.columns )
    p.columns = :bacon
    assert_equal( :bacon, p.columns )
    p.columns( :chunky )
    assert_equal( :chunky, p.columns )
    assert_equal( :alice, p2.columns )
  end

  def test_parameters
    p = Class.new( Momomoto::Procedure )
    p2 = Class.new( Momomoto::Procedure )
    p.parameters = { :chunky => :bacon }
    p2.parameters = { :bacon => :chunky }
    assert_equal( [{:chunky=>:bacon}], p.parameters )
    assert_equal( [{:bacon=>:chunky}], p2.parameters )
    p.parameters( {:alice=>:bob},{:eve=>:mallory})
    assert_equal( [{:alice=>:bob},{:eve=>:mallory}], p.parameters )
    assert_equal( [{:bacon=>:chunky}], p2.parameters )
  end

  def test_call
    self.class.const_set(:Test_set_returning, Class.new( Momomoto::Procedure ) )
    assert_equal( "test_set_returning", Test_set_returning.procedure_name )
    Test_set_returning.parameters(:person_id => Momomoto::Datatype::Integer.new)
    assert_not_nil( Test_set_returning.parameters )
    assert_not_nil( Test_set_returning.columns )
    assert( Test_set_returning.columns.length > 1 )
    Test_set_returning.call( :person_id => 5 )
    Test_set_returning.call({:person_id => 5},{:person_id => 5},{:order=>:person_id,:limit=>10} )
  end

end

