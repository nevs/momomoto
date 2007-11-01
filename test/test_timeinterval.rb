
class TestTimeInterval < Test::Unit::TestCase

  def test_parse
    ["00:00:00","00:05:00","00:00:23","00:05:23","05:00:00","42:00:00","42:05:23"].each do | number |
      i = TimeInterval.parse( number )
      assert_equal( i.to_s, number )
    end
    assert_raise( TimeInterval::ParseError ) do TimeInterval.parse("u") end
    assert_raise( TimeInterval::ParseError ) do TimeInterval.parse("2023-05-05 23:05:00") end
  end

  def test_to_i
    examples = { "00:00:00" => 0, "0:00:00" => 0, "000:00:00" => 0, "01:00:00" => 3600, "00:00:01" => 1, "00:01:00" => 60, "01:01:00" => 3660, "02:00:00" => 7200, "40:00:00" => 144000 }
    examples.each do | string, number |
      i = TimeInterval.parse( string )
      assert_equal( i.to_i, number )
      assert_equal( i.to_int, number )
    end
  end

  def test_strftime
    i = TimeInterval.parse( "23:00:05" )
    assert_equal( "23", i.strftime("%H"))
    assert_equal( "00", i.strftime("%M"))
    assert_equal( "05", i.strftime("%S"))
    assert_equal( "%", i.strftime("%%"))
    assert_equal( "%A", i.strftime("%A"))
  end

  def test_comparison
    assert( TimeInterval.new( 0 ) < TimeInterval.new( 2 ) )
    assert( TimeInterval.new( 42 ) > TimeInterval.new( 5 ) )
    assert( TimeInterval.new( 23 ) == TimeInterval.new( 23 ) )
    assert( TimeInterval.new( "0:00:00" ) == TimeInterval.new( 0 ) )
    assert( TimeInterval.new( "01:00:00" ) == TimeInterval.new( "1:00:00" ) )
  end

end

