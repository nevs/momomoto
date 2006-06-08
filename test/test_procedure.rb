
class TestProcedure < Test::Unit::TestCase

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

  def test_parameter
    p = Class.new( Momomoto::Procedure )
    p2 = Class.new( Momomoto::Procedure )
    p.parameter = :chunky
    p2.parameter = :bacon
    assert_equal( :chunky, p.parameter )
    assert_equal( :bacon, p2.parameter )
    p.parameter( :alice )
    assert_equal( :alice, p.parameter )
    assert_equal( :bacon, p2.parameter )
  end

  def test_call
    self.class.const_set(:Test_parameter, Class.new( Momomoto::Procedure ) )
    assert_equal( "test_parameter", Test_parameter.procedure_name )
    Test_parameter.parameter(:person_id => Momomoto::Datatype::Integer.new)
    assert_not_nil( Test_parameter.parameter )
    Test_parameter.columns(
        :person_id => Momomoto::Datatype::Integer.new,
        :first_name => Momomoto::Datatype::Text.new,
        :last_name => Momomoto::Datatype::Text.new )
    assert_not_nil( Test_parameter.columns )
    Test_parameter.call( :person_id => 5 )
    Test_parameter.call({:person_id => 5},{:person_id => 5},{:order=>:person_id,:limit=>10} )
  end

end

