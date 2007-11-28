
module Momomoto

  module Information_schema

    # internal use only
    #
    # Represents the corresponding view from Information Schema and is
    # used for getting all defined functions within a database.
    class Routines < Momomoto::Table
      schema_name( "information_schema" )
    end

  end

end
