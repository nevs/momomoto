
module Momomoto::Information_schema 

  def self.const_missing( table )
    raise CriticalError, "Invalid name." unless table.to_s.downcase.match(/^[a-z0-9_]+$/)
    begin
      require "momomoto/information_schema/#{table.to_s.downcase}"
      ::Momomoto::Information_schema::const_get( table )
    rescue LoadError
      klass = Class.new( ::Momomoto::Table )
      klass.schema_name = "information_schema"
      klass.table_type = "VIEW"
      klass.primary_keys( [] )

      ::Momomoto::Information_schema.const_set(table, klass)
    end
  end

end

