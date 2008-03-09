
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
    p1 = Class.new( Momomoto::Procedure )
    p1.procedure_name = 'test_parameter_sql'
    assert_equal( 'test_parameter_sql', p1.procedure_name )
    p2 = Class.new( Momomoto::Procedure )
    p2.procedure_name = 'test_parameter_sql_strict'
    assert_equal( 'test_parameter_sql_strict', p2.procedure_name )
    p2.procedure_name( 'proc3' )
    assert_equal( 'proc3', p2.procedure_name )
    p2.procedure_name = 'proc4'
    assert_equal( 'proc4', p2.procedure_name )
    assert_equal( 'test_parameter_sql', p1.procedure_name )
  end

  def test_columns_fetching
    p = Class.new( Momomoto::Procedure )
    p.procedure_name = 'fetch_procedure_columns'
    p.schema_name = 'momomoto'
    assert_equal( 2, p.columns.length )
  end

  def test_columns
    p = Class.new( Momomoto::Procedure )
    p.procedure_name("test_parameter_plpgsql")
    p2 = Class.new( Momomoto::Procedure )
    p2.procedure_name("test_parameter_plpgsql")
    p.columns = { :chunky => :bacon }
    p2.columns = { :bacon => :chunky }
    assert_equal( {:chunky=>:bacon}, p.columns )
    p.columns = :bacon
    assert_equal( :bacon, p.columns )
    p.columns = { :chunky => :bacon }
    assert_equal( {:chunky=>:bacon}, p.columns )
    assert_equal( {:bacon=>:chunky}, p2.columns )
  end

  def test_parameters
    p = Class.new( Momomoto::Procedure )
    p.procedure_name("test_parameter_plpgsql")
    p2 = Class.new( Momomoto::Procedure )
    p2.procedure_name("test_parameter_plpgsql")
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

  def test_returns_void
    self.class.const_set(:Test_returns_void, Class.new( Momomoto::Procedure ) )
    assert_equal( "test_returns_void", Test_returns_void.procedure_name )
    Test_returns_void.call()
  end

  def test_call_strict
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_sql")
    assert_equal( false, a.parameters[0][:param1].not_null? )
    assert_raise( Momomoto::Error ) { a.call }
    assert_nothing_raised { a.call({:param1=>nil})}
    assert_nothing_raised { a.call({:param1=>1})}

    b = Class.new(Momomoto::Procedure)
    b.procedure_name("test_parameter_sql_strict")
    assert_equal( true, b.parameters[0][:param1].not_null? )
    assert_raise( Momomoto::Error ) { b.call }
    assert_raise( Momomoto::Error ) { b.call({:param1=>nil})}
    assert_nothing_raised { b.call({:param1=>1})}
  end

  def test_inout_sql
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_inout_sql")
    assert_equal( 1, a.columns.keys.length )
    assert_instance_of( Momomoto::Datatype::Integer, a.columns[:ret1] )
    assert_equal( 1, a.parameters.length )
    assert_instance_of( Momomoto::Datatype::Integer, a.parameters.first[:param1] )
  end

  def test_inout_plpgsql
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_inout_plpgsql")
    assert_equal( 1, a.columns.keys.length )
    assert_instance_of( Momomoto::Datatype::Integer, a.columns[:ret1] )
    assert_equal( 2, a.parameters.length )
    assert_instance_of( Momomoto::Datatype::Integer, a.parameters[0][:param1] )
    assert_instance_of( Momomoto::Datatype::Text, a.parameters[1][:param2] )
  end

  def test_set_returning_inout
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_set_returning_inout")
    assert_equal( 2, a.columns.keys.length )
    assert_instance_of( Momomoto::Datatype::Integer, a.columns[:ret1] )
    assert_instance_of( Momomoto::Datatype::Text, a.columns[:ret2] )
    assert_equal( 1, a.parameters.length )
    assert_instance_of( Momomoto::Datatype::Integer, a.parameters[0][:param1] )
  end

  def test_parameter_inout_unnamed
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_inout_unnamed")
    assert_equal( 1, a.columns.keys.length )
    assert_equal( :test_parameter_inout_unnamed, a.columns.keys.first )
    assert_instance_of( Momomoto::Datatype::Integer, a.columns[:test_parameter_inout_unnamed] )
    assert_equal( 1, a.parameters.length )
    assert_equal( :test_parameter_inout_unnamed, a.parameters.first.keys.first )
    assert_instance_of( Momomoto::Datatype::Integer, a.parameters[0][:test_parameter_inout_unnamed] )
  end

  def test_parameter_inout_unnamed2
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_inout_unnamed2")
    assert_equal( 1, a.columns.keys.length )
    assert_equal( :test_parameter_inout_unnamed2, a.columns.keys.first )
    assert_instance_of( Momomoto::Datatype::Integer, a.columns[:test_parameter_inout_unnamed2] )
    assert_equal( 1, a.parameters.length )
    assert_equal( :param1, a.parameters.first.keys.first )
    assert_instance_of( Momomoto::Datatype::Integer, a.parameters[0][:param1] )
  end

  def test_parameter_inout_unnamed3
    a = Class.new(Momomoto::Procedure)
    a.procedure_name("test_parameter_inout_unnamed3")
    assert_equal( 1, a.columns.keys.length )
    assert_equal( :ret1, a.columns.keys.first )
    assert_instance_of( Momomoto::Datatype::Integer, a.columns[:ret1] )
    assert_equal( 1, a.parameters.length )
    assert_equal( :test_parameter_inout_unnamed3, a.parameters.first.keys.first )
    assert_instance_of( Momomoto::Datatype::Integer, a.parameters[0][:test_parameter_inout_unnamed3] )
  end

end

