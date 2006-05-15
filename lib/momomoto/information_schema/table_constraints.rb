
module Momomoto
  module Information_schema
    class Table_constraints < Momomoto::Table
      primary_keys( [] )
      columns( { :constraint_catalog        => Momomoto::Datatype::Text.new,
                 :constraint_schema         => Momomoto::Datatype::Text.new,
                 :constraint_name           => Momomoto::Datatype::Text.new,
                 :table_catalog             => Momomoto::Datatype::Text.new,
                 :table_schema              => Momomoto::Datatype::Text.new,
                 :table_name                => Momomoto::Datatype::Text.new,
                 :constraint_type           => Momomoto::Datatype::Text.new,
                 :is_deferrable             => Momomoto::Datatype::Text.new,
                 :initially_deferred        => Momomoto::Datatype::Text.new
               } )
    end
  end
end
