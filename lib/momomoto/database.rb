
begin
  require 'postgres'
rescue LoadError
  require 'rubygems'
  require 'postgres'
end

require 'momomoto/information_schema/columns'
require 'momomoto/information_schema/table_constraints'
require 'momomoto/information_schema/key_column_usage'

## Momomoto is a database abstraction layer
module Momomoto

  ## Momomoto Connection class
  class Database

    # establish connection to the database
    # expects a hash with the following keys: host, port, database, 
    # username, password, pgoptions and pgtty
    def initialize( config )
      # we also accept String keys in the config hash 
      config.each do | key, value |
        config[key.to_sym] = value unless key.kind_of?( Symbol )
        config[key.to_sym] = value.to_s if value.kind_of?(Symbol)
      end

      @connection = connect( config )
      Momomoto::Base.send( :class_variable_set, :@@database, self )
    end

    def connect( config )
      PGconn.connect( config[:host], config[:port], config[:pgoptions],
                      config[:pgtty], config[:database], config[:username],
                      config[:password])
    rescue => e
      raise CriticalError, "Connection to database failed: #{e}"
    end

    # terminate this connection
    def disconnect
      @connection.close
    end

    # execute a query
    def execute( sql ) # :nodoc:
      result = @connection.exec( sql )
      rows = result.entries
      result.clear
      rows
    end

    # fetch columns which are primary key columns
    def fetch_primary_keys( table_name, schema_name = nil ) # :nodoc:
      pkeys = []
      conditions = {:table_name=>table_name, :constraint_type => 'PRIMARY KEY'}
      conditions[:table_schema] = schema_name if schema_name
      keys = Momomoto::Information_schema::Table_constraints.select( conditions )
      if keys.length != 0
        cols = Momomoto::Information_schema::Key_column_usage.select( 
            { :table_name => keys[0].table_name, 
              :table_schema => keys[0].table_schema, 
              :constraint_name => keys[0].constraint_name,
              :constraint_schema => keys[0].constraint_schema } )
        cols.each do | key |
          pkeys << key.column_name.to_sym
        end
      end
      pkeys
    end

    # fetch column definitions from database
    def fetch_columns( table_name, schema_name = nil ) # :nodoc:
      columns = {}
      conditions = { :table_name=>table_name }
      conditions[:table_schema] = schema_name if schema_name
      cols = Momomoto::Information_schema::Columns.select( conditions )
      cols.each do  | col |
        columns[col.column_name.to_sym] = Momomoto::Datatype.const_get(col.data_type.gsub(' ','_').capitalize).new( col )
      end
      columns
    end

  end

end

