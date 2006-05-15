
## Momomoto is a database abstraction layer
module Momomoto

  ## base exception for all exceptions thrown by Momomoto
  class Error < StandardError; end

  class CriticalError < Error; end

  ## Momomoto base class for Table, Procedure and Join
  class Base
    include Enumerable

    def initialize( values = {}, options = {} )
      if [Base, Table, Procedure, Join].member?( self.class )
        raise CriticalError, "This is a virtual class and should never be initialized." 
      end
      unless self.class.class_variables.member?('@@initialized')
        initialize_class
        # mark class as initialized
        self.class.send(:class_variable_set, :@@initialized, true)
      end
    end

    # guesses the schema name of the table this class works on
    def self.construct_schema_name( classname ) # :nodoc:
      schema = classname.split('::')[-2]
      schema ? schema.downcase.gsub(/[^a-z_0-9]/, '') : nil
    end

    # set the columns of the table this class operates on
    def self.columns=( columns )
      send(:class_variable_set, :@@columns, columns)
    end

    # get the columns of the table this class operates on
    def self.columns( columns = nil )
      return self.columns=( columns ) if columns
      begin
        send(:class_variable_get, :@@columns)
      rescue NameError
        nil
      end
    end

    # set the schema name of the table this class operates on
    def self.schema_name=( schema_name )
      send(:class_variable_set, :@@schema_name, schema_name)
    end

    # get the schema name of the table this class operates on
    def self.schema_name( schema_name  = nil )
      return self.schema_name=( schema_name ) if schema_name
      begin
        send(:class_variable_get, :@@schema_name)
      rescue NameError
        construct_schema_name( self.name )
      end
    end

    # iterate over resultset
    def each( &block )
      @data.each( &block )
    end

    # get a specific resultset
    def []( index )
      @data[ index ]
    end

    # return the number of records in the current resultset
    def length
      @data.length
    end

    protected
    
    # get the database connection
    def self.database # :nodoc:
      @@database
    rescue
      raise Momomoto::CriticalError, "No database connection setup."
    end

    # compiles the where-clause of the query
    def compile_where( conditions ) # :nodoc:
      where = ''
      conditions.each do | key , value |
        raise CriticalError unless self.class.columns.member?( key )
        where = where_append( where,  "#{key} = #{Datatype::Text.escape(value)}" )
      end
      where
    end

    # append where string
    def where_append( where, append ) # :nodoc:
      ( where.empty? ? ' WHERE ' : where + ' AND ' ) + append
    end

  end

end

