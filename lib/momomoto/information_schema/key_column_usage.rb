
module Momomoto
  module Information_schema
    class Key_column_usage < Momomoto::Table
      primary_keys( [] )
      schema_name( "information_schema" )
      columns( { :constraint_catalog        => Momomoto::Datatype::Character_varying.new,
                 :constraint_schema         => Momomoto::Datatype::Character_varying.new,
                 :constraint_name           => Momomoto::Datatype::Character_varying.new,
                 :table_catalog             => Momomoto::Datatype::Character_varying.new,
                 :table_schema              => Momomoto::Datatype::Character_varying.new,
                 :table_name                => Momomoto::Datatype::Character_varying.new,
                 :column_name               => Momomoto::Datatype::Character_varying.new,
                 :ordinal_position          => Momomoto::Datatype::Integer.new
               } )
    end
  end
end

