
class TestText < Test::Unit::TestCase

  def test_default_getter
    row = Momomoto::Information_schema::Columns.create
    row.column_default = 'default'
    a = Momomoto::Datatype::Text.new( row )
    assert_equal( 'default', a.default )
  end

  def test_default_setter
  end

  def test_not_null
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
    dt = Momomoto::Datatype::Text
    assert_equal( '<=', dt.operator_sign( :le ) )
    assert_equal( '<', dt.operator_sign( :lt ) )
    assert_equal( '>=', dt.operator_sign( :ge ) )
    assert_equal( '>', dt.operator_sign( :gt ) )
    assert_equal( '=', dt.operator_sign( :eq ) )
    assert_equal( '<>', dt.operator_sign( :ne ) )
    assert_raise( Momomoto::CriticalError ) { dt.operator_sign( :foo ) }
  end

  def test_escape
  end

end

