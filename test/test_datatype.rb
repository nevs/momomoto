
class TestDatatype < Test::Unit::TestCase

  DATATYPES = Momomoto::Datatype.constants.map do | t | 
    Momomoto::Datatype.const_get( t ) 
  end

  def test_default
    DATATYPES.each do | type |
      row = Momomoto::Information_schema::Columns.new
      row.column_default = 'default-value'
      a = type.new( row )
      assert_equal( 'default-value', a.default )
      assert_equal( false, type.new.default )
    end
  end

  def test_not_null
    DATATYPES.each do | type |
      row = Momomoto::Information_schema::Columns.new
      row.is_nullable = "YES"
      assert_equal( false, type.new( row ).not_null? )
      row.is_nullable = "NO"
      assert_equal( true, type.new( row ).not_null? )
      row.is_nullable = nil
      assert_equal( false, type.new( row ).not_null? )
    end
  end

  def test_compile_rule
    DATATYPES.each do | type |
      t = type.new
      tests = [ nil, [], [nil], [nil,nil], {}, {:eq=>nil}, {nil=>nil}]
      tests.each do | test |
        assert_raise( Momomoto::Error ) do
          t.compile_rule( :field_name, test )
        end
      end
    end
  end

  def test_compile_rule_null
    DATATYPES.each do | type |
      t = type.new
      assert_equal( "field_name IS NULL", t.compile_rule( :field_name, :NULL) )
      assert_equal( "field_name IS NOT NULL", t.compile_rule( :field_name, :NOT_NULL) )
    end
  end

  def test_operator_sign
    DATATYPES.each do | type |
      assert_equal( '<=', type.operator_sign( :le ) )
      assert_equal( '<', type.operator_sign( :lt ) )
      assert_equal( '>=', type.operator_sign( :ge ) )
      assert_equal( '>', type.operator_sign( :gt ) )
      assert_equal( '=', type.operator_sign( :eq ) )
      assert_equal( '<>', type.operator_sign( :ne ) )
      assert_raise( Momomoto::CriticalError ) { type.operator_sign( :foo ) }
    end
  end

  def test_escape
    DATATYPES.each do | type |
      t = type.new
      assert_equal( 'NULL', t.escape( nil ))
    end
  end

end

