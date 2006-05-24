
module Momomoto
  # class without instance methods
  class BlankSlate
    instance_methods.each do | method_name |
      next if method_name.match( /^__/ )
      next if [:class, :send, :inspect, :instance_variable_set, :instance_variable_get, :respond_to?].member?( method_name.to_sym )
#      undef_method( method_name )
    end
  end
end
