
class TestTime_without_time_zone < Test::Unit::TestCase

  def test_default
    row = Momomoto::Information_schema::Columns.create
    row.column_default = 'default-value'
    a = Momomoto::Datatype::Time_without_time_zone.new( row )
    assert_equal( 'default-value', a.default )
    assert_equal( false, Momomoto::Datatype::Time_without_time_zone.new.default )
  end

  def test_not_null
    row = Momomoto::Information_schema::Columns.create
    row.is_nullable = "YES"
    assert_equal( false, Momomoto::Datatype::Time_without_time_zone.new( row ).not_null? )
    row.is_nullable = "NO"
    assert_equal( true, Momomoto::Datatype::Time_without_time_zone.new( row ).not_null? )
    row.is_nullable = nil
    assert_equal( false, Momomoto::Datatype::Time_without_time_zone.new( row ).not_null? )
  end

  def test_operator_sign
    dt = Momomoto::Datatype::Time_without_time_zone
    assert_equal( '<=', dt.operator_sign( :le ) )
    assert_equal( '<', dt.operator_sign( :lt ) )
    assert_equal( '>=', dt.operator_sign( :ge ) )
    assert_equal( '>', dt.operator_sign( :gt ) )
    assert_equal( '=', dt.operator_sign( :eq ) )
    assert_equal( '<>', dt.operator_sign( :ne ) )
    assert_raise( Momomoto::CriticalError ) { dt.operator_sign( :foo ) }
  end

end

