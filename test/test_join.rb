
class Person < Momomoto::Table; end
class Event_Person < Momomoto::Table; end

class TestJoin < Test::Unit::TestCase

  def test_initialize
    a = Momomoto::Join.new( Person, {Event_Person=>:person_id})
    assert_equal( true, a.respond_to?( :event_person ) )
    assert_equal( true, a.respond_to?( :person ) )
  end

  def test_class_variable_set
    self.class.const_set( :CVST, Class.new( Momomoto::Join ) )
    CVST.send(:define_method, :initialize) do end
    a = CVST.new
    assert_raise( NameError ) do a.class.send( :class_variable_get,  :@@sven ) end
    a.class_variable_set( :@@sven, true )
    assert_equal( true, a.class.send( :class_variable_get, :@@sven ) )
  end

  def test_select
    a = Momomoto::Join.new( Person, {Event_Person=>:person_id})
    a.select
  end

end

