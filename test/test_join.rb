
$LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ), '..', 'lib' ) )

require 'momomoto'
require 'test/unit'

class Person < Momomoto::Table; end
class Event_Person < Momomoto::Table; end

class TestJoin < Test::Unit::TestCase

  def setup
    Momomoto::Database.instance.config('database'=>'pentabarf','username'=>'pentabarf')
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

  def test_initialize
    a = Momomoto::Join.new( Person, {Event_Person=>:person_id}) 
    assert_equal( true, a.respond_to?( :event_person ) )
    assert_equal( true, a.respond_to?( :person ) )
  end

  def test_select
    a = Momomoto::Join.new( Person, {Event_Person=>:person_id}) 
    a.select
  end

end

