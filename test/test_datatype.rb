
class TestDatatype < Test::Unit::TestCase

  Momomoto::Datatype.constants.each do | type_name | 
    type = Momomoto::Datatype.const_get( type_name ) 

    define_method( "test_default_#{type_name}" ) do
      row = Momomoto::Information_schema::Columns.new
      row.column_default = 'default-value'
      a = type.new( row )
      assert_equal( 'default-value', a.default )
      assert_equal( nil, type.new.default )
    end

    define_method( "test_not_null_#{type_name}" ) do
      row = Momomoto::Information_schema::Columns.new
      row.is_nullable = "YES"
      assert_equal( false, type.new( row ).not_null? )
      row.is_nullable = "NO"
      assert_equal( true, type.new( row ).not_null? )
      row.is_nullable = nil
      assert_equal( false, type.new( row ).not_null? )
    end

    define_method( "test_compile_rule_#{type_name}" ) do
      t = type.new
      tests = [ nil, [], [nil], [nil,nil], {}, {:eq=>nil}, {nil=>nil}]
      tests.each do | test |
        assert_raise( Momomoto::Error ) do
          t.compile_rule( :field_name, test )
        end
      end
    end

    define_method( "test_compile_rule_null_#{type_name}" ) do
      t = type.new
      assert_equal( "field_name IS NULL", t.compile_rule( :field_name, :NULL) )
      assert_equal( "field_name IS NOT NULL", t.compile_rule( :field_name, :NOT_NULL) )
    end

    define_method( "test_operator_sign_#{type_name}" ) do
      assert_equal( '<=', type.operator_sign( :le ) )
      assert_equal( '<', type.operator_sign( :lt ) )
      assert_equal( '>=', type.operator_sign( :ge ) )
      assert_equal( '>', type.operator_sign( :gt ) )
      assert_equal( '=', type.operator_sign( :eq ) )
      assert_equal( '<>', type.operator_sign( :ne ) )
      assert_raise( Momomoto::CriticalError ) { type.operator_sign( :foo ) }
    end

    define_method( "test_escape_#{type_name}" ) do
      t = type.new
      assert_equal( 'NULL', t.escape( nil ))
    end
  end

end

