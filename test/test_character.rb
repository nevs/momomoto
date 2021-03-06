
class TestCharacter < Test::Unit::TestCase

  def test_nil
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_character'
    r = c.new( :data => nil )
    assert_equal( nil, r.data )
    r.write
    r2 = c.select( :id => r.id ).first
    assert_equal( nil, r2.data )
  end

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_character'
    ['a',"'","''","\\","a'b"].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data.rstrip )
    end
  end

end

