
class TestNumeric < Test::Unit::TestCase

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_numeric'
    [nil,1.0,2.0,2.3].each do | number |
      r = c.new( :data => number )
      assert_equal( number, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( number, r2.data )
    end
  end

end

