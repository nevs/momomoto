
class TestArray < Test::Unit::TestCase

  def test_int_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_int_array'
    [[1,2,3],nil,[],[1]].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
      r.delete
    end
  end

  def test_text_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_text_array'
    [['chunky','bacon'],nil,[],['foo']].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
      r.delete
    end
  end

end

