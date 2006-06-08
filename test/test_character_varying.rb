
class TestCharacter_varying < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_samples
    c = Class.new( Momomoto::Table )
    c.table_name = 'test_character_varying'
    [nil,'a',"'","''","\\","a'b"].each do | value |
      r = c.new( :data => value )
      assert_equal( value, r.data )
      r.write
      r2 = c.select(:id=>r.id).first
      assert_equal( value, r2.data )
    end
  end

end

