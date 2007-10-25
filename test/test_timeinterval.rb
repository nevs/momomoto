
class TestTimeInterval < Test::Unit::TestCase


  def test_parse
    ["00:00:00","00:05:00","00:00:23","00:05:23","05:00:00","42:00:00","42:05:23"].each do | number |
      i = TimeInterval.parse( number )
      assert_equal( i.to_s, number )
    end
  end

  def test_to_i
    examples = { "00:00:00" => 0, "0:00:00" => 0, "000:00:00" => 0, "01:00:00" => 3600, "00:00:01" => 1, "00:01:00" => 60, "01:01:00" => 3660, "02:00:00" => 7200, "40:00:00" => 144000 }
    examples.each do | string, number |
      i = TimeInterval.parse( string )
      assert_equal( i.to_i, number )
      assert_equal( i.to_int, number )
    end
  end



end
