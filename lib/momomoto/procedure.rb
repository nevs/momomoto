
module Momomoto

  # this class implements access to stored procedures
  # it must not be used directly but you should inherit from this class
  class Procedure < Base

    # guesses the procedure name of the procedure this class works on
    def self.construct_procedure_name( classname ) # :nodoc:
      classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
    end

    # set the procedure_name of the table this class operates on
    def self.procedure_name=( procedure_name )
      class_variable_set( :@@procedure_name, procedure_name )
    end

    # get the procedure_name of the table this class operates on
    def self.procedure_name( procedure_name = nil )
      return self.procedure_name=( procedure_name ) if procedure_name
      begin
        class_variable_get( :@@procedure_name )
      rescue NameError
        construct_procedure_name( self.name )
      end
    end

  end

end

