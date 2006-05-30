
module Momomoto

  # this class implements access to stored procedures
  # it must not be used directly but you should inherit from this class
  class Procedure < Base

    class << self

      # guesses the procedure name of the procedure this class works on
      def construct_procedure_name( classname ) # :nodoc:
        classname.split('::').last.downcase.gsub(/[^a-z_0-9]/, '')
      end

      # set the procedure name
      def procedure_name=( procedure_name )
        class_variable_set( :@@procedure_name, procedure_name )
      end

      # get the procedure name
      def procedure_name( procedure_name = nil )
        return self.procedure_name=( procedure_name ) if procedure_name
        begin
          class_variable_get( :@@procedure_name )
        rescue NameError
          construct_procedure_name( self.name )
        end
      end

      # set the parameter this procedures accepts
      def parameter=( parameter )
        class_variable_set( :@@parameter, parameter)
      end

      # get the parameter this procedure accepts
      def parameter( parameter = nil )
        return self.parameter=( parameter ) if parameter
        begin
          class_variable_get( :@@parameter )
        rescue NameError
          nil
        end
      end

      # get the columns of the resultset this procedure returns
      def columns=( columns )
        class_variable_set( :@@columns, columns)
      end

      # get the columns of the resultset this procedure returns
      def columns( columns = nil )
        return self.columns=( columns ) if columns
        begin
          class_variable_get( :@@columns )
        rescue NameError
          nil
        end
      end

    end

  end

end

