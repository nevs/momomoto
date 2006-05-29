
class TestText < Test::Unit::TestCase

  def test_operator_sign
    type = Momomoto::Datatype::Text
      assert_equal( 'LIKE', type.operator_sign( :like ) )
      assert_equal( 'ILIKE', type.operator_sign( :ilike ) )
      assert_raise( Momomoto::CriticalError ) { type.operator_sign( :foo ) }
  end

end

