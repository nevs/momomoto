
class TestInteger < Test::Unit::TestCase

  def test_filter_set
    t = Momomoto::Datatype::Integer.new
    assert_equal( nil, t.filter_set( nil ) )
    assert_equal( 1, t.filter_set( 1 ) )
    assert_equal( 1, t.filter_set( '1' ) )
  end

  def test_filter_get
    t = Momomoto::Datatype::Integer.new
    assert_equal( nil, t.filter_get( nil ) )
    assert_equal( 1, t.filter_get( 1 ) )
    assert_equal( 1, t.filter_get( '1' ) )
    assert_raise( Momomoto::Error ) do t.filter_set( "1a2" ) end
  end

  def test_compile_rule
    t = Momomoto::Datatype::Integer.new
    input = [ 1, '1', [1], ['1'], [1,2,3],['1','2','3'], {:eq=>1}, {:eq=>'1'}, {:lt=>10, :gt=>5}, {:lt=>'10', :gt=>'5'} ]
  
    input.each do | test_input |
      assert_instance_of( String, t.compile_rule( :field, test_input ) )
    end
  end

end

