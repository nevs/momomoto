
## Momomoto is a database abstraction layer
module Momomoto

  ## base exception for all exceptions thrown by Momomoto
  class Error < StandardError; end

  class CriticalError < Error; end

  ## Momomoto base class for Table, Procedure and Join
  class Base

    def class_variable_set( variable, value ) # :nodoc:
      self.class.send( :class_variable_set, variable, value )
    end

    def initialize( values = {}, options = {} )
      raise CriticalError, "This is a virtual class and should never be initialized." 
    end

    # guesses the schema name of the table this class works on
    def self.construct_schema_name( classname ) # :nodoc:
      schema = classname.split('::')[-2]
      schema ? schema.downcase.gsub(/[^a-z_0-9]/, '') : nil
    end

    # set the columns of the table this class operates on
    def self.columns=( columns )
      class_variable_set( :@@columns, columns)
    end

    # get the columns of the table this class operates on
    def self.columns( columns = nil )
      return self.columns=( columns ) if columns
      begin
        class_variable_get( :@@columns )
      rescue NameError
        nil
      end
    end

    # set the schema name of the table this class operates on
    def self.schema_name=( schema_name )
      class_variable_set( :@@schema_name, schema_name )
    end

    # get the schema name of the table this class operates on
    def self.schema_name( schema_name  = nil )
      return self.schema_name=( schema_name ) if schema_name
      begin
        class_variable_get( :@@schema_name )
      rescue NameError
        construct_schema_name( self.name )
      end
    end

    # begin a transaction
    def begin
      database.execute( "BEGIN;" )
    end

    # commit the current transaction
    def commit
      database.execute( "COMMIT;" )
    end

    # roll the transaction back
    def rollback
      database.execute( "ROLLBACK;" )
    end

    protected
    
    # get the database connection
    def self.database # :nodoc:
      Momomoto::Database.instance
    end

    # compiles the where-clause of the query
    def self.compile_where( conditions ) # :nodoc:
      where = ''
      conditions.each do | key , value |
        key = key.to_sym if key.kind_of?( String )
        raise CriticalError unless columns.keys.member?( key )
        where = where_append( where, columns[key].compile_rule( key, value ) )
      end
      where
    end

    # append where string
    def self.where_append( where, append ) # :nodoc:
      ( where.empty? ? ' WHERE ' : where + ' AND ' ) + append
    end

  end

end

