
module Momomoto
  module Information_schema

    # internal use only
    #
    # Represents the corresponding view from Information Schema and is
    # used for getting the column names of primary keys of a table.
    class Key_column_usage < Momomoto::Table
      schema_name( "information_schema" )
    end
  end
end

