
class TestProcedure < Test::Unit::TestCase

  def test_procedure_name_getter
    self.class.const_set( :Proc1, Class.new( Momomoto::Procedure ) )
    assert_equal( 'proc1', Proc1.procedure_name )
  end

  def test_procedure_name_setter
    self.class.const_set( :Proc2, Class.new( Momomoto::Procedure ) )
    assert_equal( 'proc2', Proc2.procedure_name )
    Proc2.procedure_name( 'proc3' )
    assert_equal( 'proc3', Proc2.procedure_name )
    Proc2.procedure_name = 'proc4'
    assert_equal( 'proc4', Proc2.procedure_name )
  end

end

