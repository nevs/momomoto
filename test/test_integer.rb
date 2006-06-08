
class TestInteger < Test::Unit::TestCase

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_integer'
    [nil,1,2,2147483647].each do | number |
      r = c.new( :data => number )
      assert_equal( number, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( number, r2.data )
    end
  end

  def test_compile_rule
    t = Momomoto::Datatype::Integer.new
    input = [ 1, '1', [1], ['1'], [1,2,3],['1','2','3'], {:eq=>1}, {:eq=>'1'}, {:lt=>10, :gt=>5}, {:lt=>'10', :gt=>'5'} ]

    input.each do | test_input |
      assert_instance_of( String, t.compile_rule( :field, test_input ) )
    end
  end

end

