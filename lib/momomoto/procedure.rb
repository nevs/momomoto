
module Momomoto

  # this class implements access to stored procedures
  # it must not be used directly but you should inherit from this class
  class Procedure < Base

    def initialize_class
      self.class.class_eval do 
        unless class_variables.member?( '@@table_name' )
          table_name( construct_table_name( self.name ) )
        end
      end
    end

    # set the procedure_name of the table this class operates on
    def self.procedure_name=( procedure_name )
      send(:class_variable_set, :@@procedure_name, procedure_name)
    end

    # get the procedure_name of the table this class operates on
    def self.procedure_name( procedure_name = nil )
      return self.procedure_name=( procedure_name ) if procedure_name
      begin
        send(:class_variable_get, :@@procedure_name)
      rescue NameError
        construct_procedure_name( self.name )
      end
    end

  end

end

