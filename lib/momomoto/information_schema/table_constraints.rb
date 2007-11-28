
module Momomoto
  module Information_schema

    # internal use only
    #
    # Represents the corresponding view from Information Schema and is
    # used when fetching primary keys.
    class Table_constraints < Momomoto::Table
      primary_keys( [] )
      schema_name( "information_schema" )
    end
  end
end
