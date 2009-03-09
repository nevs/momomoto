
module Momomoto::Information_schema 

  def self.const_missing( table )
    klass = Class.new( ::Momomoto::Table )
    klass.schema_name = "information_schema"
    klass.table_type = "VIEW"
    klass.primary_keys( [] )

    ::Momomoto::Information_schema.const_set(table, klass)
  end

end

