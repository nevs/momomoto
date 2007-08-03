
class TestBase < Test::Unit::TestCase

  def test_compile_where
    t = Class.new( Momomoto::Table )
    t.table_name = 'person'
    t.columns
    assert_equal( " WHERE person_id = '1'" , t.compile_where( :person_id => '1' ) )
    assert_equal( " WHERE person_id IN ('1')" , t.compile_where( :person_id => ['1'] ) )
    assert_equal( " WHERE person_id IN ('1','2')" , t.compile_where( :person_id => ['1',2] ) )
    assert_equal( " WHERE first_name = E'1'" , t.compile_where( :first_name => '1' ) )
    assert_equal( " WHERE first_name = E'chu''nky'" , t.compile_where( :first_name => "chu'nky" ) )
    assert_equal( " WHERE first_name IN (E'chu''nky',E'bac''n')" , t.compile_where( :first_name => ["chu'nky","bac'n"] ) )
  end

end

