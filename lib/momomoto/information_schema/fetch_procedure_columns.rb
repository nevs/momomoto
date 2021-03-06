
module Momomoto
  module Information_schema

    # internal use only
    class Fetch_procedure_columns < Momomoto::Procedure
      schema_name( "momomoto" )
      parameters( :procedure_name => Momomoto::Datatype::Text.new )
      columns( { 
                 :column_name               => Momomoto::Datatype::Text.new,
                 :data_type                 => Momomoto::Datatype::Text.new
               } )
    end
  end
end

