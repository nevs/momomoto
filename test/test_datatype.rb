
class TestDatatype < Test::Unit::TestCase

  DATATYPES = Momomoto::Datatype.constants.map do | t | 
    Momomoto::Datatype.const_get( t ) 
  end

  def setup
  end

  def teardown
  end

  def test_default
    DATATYPES.each do | type |
      row = Momomoto::Information_schema::Columns.create
      row.column_default = 'default-value'
      a = type.new( row )
      assert_equal( 'default-value', a.default )
      assert_equal( false, type.new.default )
    end
  end

  def test_not_null
    DATATYPES.each do | type |
      row = Momomoto::Information_schema::Columns.create
      row.is_nullable = "YES"
      assert_equal( false, type.new( row ).not_null? )
      row.is_nullable = "NO"
      assert_equal( true, type.new( row ).not_null? )
      row.is_nullable = nil
      assert_equal( false, type.new( row ).not_null? )
    end
  end

  def test_primary_key
  end

  def test_filter_set
  end

  def test_filter_get
  end

  def test_compile_rule
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
  end

end

