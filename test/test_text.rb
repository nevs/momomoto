
class TestText < Test::Unit::TestCase

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_text'
    [nil,'a',"'","''","\\","a'b"].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
    end
  end

  def test_operator_sign
    type = Momomoto::Datatype::Text
      assert_equal( 'LIKE', type.operator_sign( :like ) )
      assert_equal( 'ILIKE', type.operator_sign( :ilike ) )
      assert_raise( Momomoto::CriticalError ) { type.operator_sign( :foo ) }
  end

end

