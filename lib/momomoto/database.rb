
begin
  require 'postgres'
rescue LoadError
  require 'rubygems'
  require 'postgres'
end

require 'singleton'

require 'momomoto/information_schema/columns'
require 'momomoto/information_schema/table_constraints'
require 'momomoto/information_schema/key_column_usage'

## Momomoto is a database abstraction layer
module Momomoto

  ## Momomoto Connection class
  class Database
    include Singleton

    # establish connection to the database
    # expects a hash with the following keys: host, port, database, 
    # username, password, pgoptions and pgtty
    def config( config )
      # we also accept String keys in the config hash 
      config.each do | key, value |
        config[key.to_sym] = value unless key.kind_of?( Symbol )
        config[key.to_sym] = value.to_s if value.kind_of?(Symbol)
      end
      @config = config
    end


    def connect
      @connection.close if @connection
      @connection = PGconn.connect( @config[:host], @config[:port], @config[:pgoptions],
                      @config[:pgtty], @config[:database], @config[:username],
                      @config[:password])
      @transaction_active = false
    rescue => e
      raise CriticalError, "Connection to database failed: #{e}"
    end

    # terminate this connection
    def disconnect
      @connection.close
      @connection = nil
      @transaction_active = true
    end

    # execute a query
    def execute( sql ) # :nodoc:
      puts sql if Momomoto::DEBUG
      result = @connection.exec( sql )
      rows = result.entries
      result.clear
      rows
     rescue => e
      raise CriticalError, e.to_s
    end

    # fetch columns which are primary key columns
    # should work with any SQL2003 compliant DBMS
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
    # should work with any SQL2003 compliant DBMS
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

    # begin a transaction
    def begin
      execute( "BEGIN;" )
      @transaction_active = true
    end

    # executes the block and commits the transaction if a block is given
    # otherwise simply starts a new transaction
    def transaction
      raise Error if @transaction_active
      self.begin
      begin
        yield
      rescue => e
        rollback
        raise e
      end
      commit
    end

    # commit the current transaction
    def commit
      raise Error if not @transaction_active
      execute( "COMMIT;" )
      @transaction_active = false
    end

    # roll the transaction back
    def rollback
      raise Error if not @transaction_active
      execute( "ROLLBACK;" )
      @transaction_active = false
    end

    def self.escape_string( input )
      PGconn.escape( input )
    end

    def self.escape_bytea( input )
      PGconn.escape_bytea( input )
    end

    def self.unescape_bytea( input )
      PGconn.unescape_bytea( input )
    end

  end

end

