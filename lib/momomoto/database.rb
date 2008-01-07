
require 'postgres'
require 'singleton'

require 'momomoto/information_schema/columns'
require 'momomoto/information_schema/table_constraints'
require 'momomoto/information_schema/key_column_usage'
require 'momomoto/information_schema/routines'
require 'momomoto/information_schema/fetch_procedure_columns'
require 'momomoto/information_schema/fetch_procedure_parameters'

## Momomoto is a database abstraction layer
module Momomoto

  ## Momomoto Connection class
  class Database
    include Singleton

    # establish connection to the database
    # expects a hash with the following keys: host, port, database,
    # username, password, pgoptions and pgtty
    def config( config )
      config ||= {}
      # we also accept String keys in the config hash
      config.each do | key, value |
        config[key.to_sym] = value unless key.kind_of?( Symbol )
        config[key.to_sym] = value.to_s if value.kind_of?(Symbol)
      end
      @config = config
    end

    # Eases the use of #config.
    def self.config( conf )
      instance.config( conf )
    end

    def initialize # :nodoc:
      @config = {}
      @connection = nil
    end

    # Connects to database
    #   Momomoto::Database.config( :database=>:test, :username => 'test' )
    #   Momomoto::Database.connect
    #   # configure and connect
    def connect
      @connection.close if @connection
      @transaction_active = false
      PGconn.translate_results = true
      @connection = PGconn.connect( @config[:host], @config[:port], @config[:pgoptions],
                      @config[:pgtty], @config[:database], @config[:username],
                      @config[:password])
    rescue => e
      raise CriticalError, "Connection to database failed: #{e}"
    end

    # Eases the use of #connect.
    #
    #   Momomoto::Database.config( :database=>:test, :username => 'test' )
    #   Momomoto::Database.connect
    #   # configure and connect
    def self.connect
      instance.connect
    end

    # terminate this connection
    def disconnect
      @connection.close
      @connection = nil
      @transaction_active = false
    end

    # execute a query
    def execute( sql ) # :nodoc:
      puts sql if Momomoto.debug
      @connection.query( sql )
     rescue => e
      if @connection.status == PGconn::CONNECTION_BAD
        begin
          connect
        rescue
        end
      end
      raise CriticalError, "#{e}: #{sql}"
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
    def fetch_table_columns( table_name, schema_name = nil ) # :nodoc:
      columns = {}
      conditions = { :table_name => table_name }
      conditions[:table_schema] = schema_name if schema_name
      cols = Momomoto::Information_schema::Columns.select( conditions )
      raise CriticalError, "Table without columns (#{table_name})" if cols.length < 1
      cols.each do  | col |
        columns[col.column_name.to_sym] = Momomoto::Datatype.const_get(col.data_type.gsub(' ','_').capitalize).new( col )
      end
      columns
    end

    # fetches parameters of a stored procedure
    def fetch_procedure_parameters( procedure_name, schema_name = nil ) # :nodoc:
      p = []
      conditions = { :procedure_name => procedure_name }
      params = Momomoto::Information_schema::Fetch_procedure_parameters.call( conditions )
      params.each do  | param |
        p << { param.parameter_name.to_sym => Momomoto::Datatype.const_get(param.data_type.gsub(' ','_').capitalize).new }
      end
      # mark parameters of strict procedures as not null
      if Information_schema::Routines.select_single(:routine_name=>procedure_name).is_null_call == 'YES'
        p.each do | param |
          param[param.keys.first].instance_variable_set(:@not_null,true)
        end
      end
      p
     rescue => e
      raise Error, "Fetching procedure parameters for #{procedure_name} failed: #{e}"
    end

    # fetches the result set columns of a stored procedure
    def fetch_procedure_columns( procedure_name, schema_name = nil ) # :nodoc:
      c = {}
      conditions = { :procedure_name => procedure_name }
      cols = Momomoto::Information_schema::Fetch_procedure_columns.call( conditions )
      cols.each do  | col |
        c[col.column_name.to_sym] = Momomoto::Datatype.const_get(col.data_type.gsub(' ','_').capitalize).new
      end
      c
    end

    # begin a transaction
    def begin
      execute( "BEGIN;" )
      @transaction_active = true
    end

    # executes the block and commits the transaction if a block is given
    # otherwise simply starts a new transaction
    def transaction
      raise Error, "Transaction active" if @transaction_active
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

    # escapes the given string +input+
    def self.escape_string( input )
      PGconn.escape( input )
    end

    # escapes the given binary data +input+
    def self.escape_bytea( input )
      PGconn.escape_bytea( input )
    end

  end

end

