
class TestBase < Test::Unit::TestCase

  def test_logical_operator
    t1 = Class.new( Momomoto::Table )
    t1.table_name = 'person'
    t1.initialize_table
    t2 = Class.new( Momomoto::Table )
    t2.table_name = 'person'
    t2.initialize_table
    assert_equal( "AND", t1.logical_operator )
    assert_equal( "AND", t2.logical_operator )
    t1.logical_operator = "OR"
    assert_equal( "OR", t1.logical_operator )
    assert_equal( "AND", t2.logical_operator )
    t1.logical_operator = "or"
    assert_equal( "OR", t1.logical_operator )
    assert_equal( " WHERE first_name = E'a' OR person_id = '1'" , t1.instance_eval do compile_where(:person_id=>'1',:first_name=>'a') end )
    assert_equal( " WHERE first_name = E'a' AND person_id = '1'" , t2.instance_eval do compile_where(:person_id=>'1',:first_name=>'a') end )
  end

  def test_compile_where
    t = Class.new( Momomoto::Table )
    t.table_name = 'person'
    t.initialize_table
      assert_equal( " WHERE person_id = '1'" , t.instance_eval do compile_where( :person_id => '1' ) end )
      assert_equal( " WHERE person_id IN ('1')" , t.instance_eval do compile_where( :person_id => ['1'] ) end )
      assert_equal( " WHERE person_id IN ('1','2')" , t.instance_eval do compile_where( :person_id => ['1',2] ) end )
      assert_equal( " WHERE first_name = E'1'" , t.instance_eval do compile_where( :first_name => '1' ) end )
      assert_equal( " WHERE first_name = E'chu''nky'" , t.instance_eval do compile_where( :first_name => "chu'nky" ) end )
      assert_equal( " WHERE first_name IN (E'chu''nky',E'bac''n')" , t.instance_eval do compile_where( :first_name => ["chu'nky","bac'n"] ) end )
  end

end

