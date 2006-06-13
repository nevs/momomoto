
module Momomoto
  module Information_schema
    class Fetch_procedure_parameters < Momomoto::Procedure
      schema_name( "momomoto" )
      parameters( :procedure_name => Momomoto::Datatype::Text.new )
      columns( { 
                 :parameter_name            => Momomoto::Datatype::Text.new,
                 :data_type                 => Momomoto::Datatype::Text.new
               } )
    end
  end
end

