
class TestArray < Test::Unit::TestCase

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_int_array'
    [["1","2","3"]].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
      r.delete
    end
  end

end

