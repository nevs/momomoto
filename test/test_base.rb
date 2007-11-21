
class TestBase < Test::Unit::TestCase

  def test_logical_operator
    t1 = Class.new( Momomoto::Table )
    t1.table_name = 'person'
    t1.send( :initialize_table )
    t2 = Class.new( Momomoto::Table )
    t2.table_name = 'person'
    t2.send( :initialize_table )
    assert_equal( "AND", t1.logical_operator )
    assert_equal( "AND", t2.logical_operator )
    t1.logical_operator = "OR"
    assert_equal( "OR", t1.logical_operator )
    assert_equal( "AND", t2.logical_operator )
    t1.logical_operator = "or"
    assert_equal( "OR", t1.logical_operator )
    assert( t1.instance_eval do compile_where(:person_id=>'1',:first_name=>'a') end.match( / OR / ) )
    assert( t2.instance_eval do compile_where(:person_id=>'1',:first_name=>'a') end.match( / AND / ) )
    assert_raise( Momomoto::Error ) do
      t1.logical_operator = "chunky"
    end
  end

  def test_compile_where
    t = Class.new( Momomoto::Table )
    t.table_name = 'person'
    t.send( :initialize_table )
    assert_equal( " WHERE person_id = '1'" , t.instance_eval do compile_where( :person_id => '1' ) end )
    assert_equal( " WHERE person_id IN ('1')" , t.instance_eval do compile_where( :person_id => ['1'] ) end )
    assert_equal( " WHERE person_id IN ('1','2')" , t.instance_eval do compile_where( :person_id => ['1',2] ) end )
    assert_equal( " WHERE first_name = E'1'" , t.instance_eval do compile_where( :first_name => '1' ) end )
    assert_equal( " WHERE first_name = E'chu''nky'" , t.instance_eval do compile_where( :first_name => "chu'nky" ) end )
    assert_equal( " WHERE first_name IN (E'chu''nky',E'bac''n')" , t.instance_eval do compile_where( :first_name => ["chu'nky","bac'n"] ) end )
    assert_equal( " WHERE (person_id = '1')" , t.instance_eval do compile_where( :OR => { :person_id => '1' } ) end )
    assert_equal( " WHERE (person_id = '1')" , t.instance_eval do compile_where( :AND => { :person_id => '1' } ) end )
    assert( [" WHERE (person_id = '1' OR first_name = E's')"," WHERE (first_name = E's' OR person_id = '1')"].member?( t.instance_eval do compile_where( :OR => { :person_id => '1',:first_name=>'s' } ) end ) )
    assert( [" WHERE (person_id = '1' AND first_name = E's')"," WHERE (first_name = E's' AND person_id = '1')"].member?( t.instance_eval do compile_where( :AND => { :person_id => '1',:first_name=>'s' } ) end ) )
    assert_equal( " WHERE (person_id = '1' AND person_id = '2')" , t.instance_eval do compile_where( :AND =>[{:person_id=>1},{:person_id=>2}] ) end )
    assert_equal( " WHERE (person_id = '1' OR person_id = '2')" , t.instance_eval do compile_where( :OR =>[{:person_id=>1},{:person_id=>2}] ) end )
    assert_equal( "" , t.instance_eval do compile_where( :OR =>[] ) end )
    assert_equal( "" , t.instance_eval do compile_where( :OR =>[{}] ) end )
    assert_equal( "" , t.instance_eval do compile_where( :AND =>[{},{}] ) end )
  end

end

