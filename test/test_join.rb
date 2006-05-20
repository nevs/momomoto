
require 'momomoto'
require 'test/unit'

class Person < Momomoto::Table; end
class Event_Person < Momomoto::Table; end

class TestJoin < Test::Unit::TestCase

  def setup
  end

  def teardown
  end

  def test_initialize
    a = Momomoto::Join.new( Person, {Event_Person=>:person_id}) 
    assert_equal( true, a.respond_to?( :event_person ) )
    assert_equal( true, a.respond_to?( :person ) )
  end

end

