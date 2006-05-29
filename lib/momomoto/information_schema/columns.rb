
module Momomoto
  module Information_schema
    class Columns < Momomoto::Table
      primary_keys( [] )
      schema_name( "information_schema" )
      columns( { :table_catalog             => Momomoto::Datatype::Text.new,
                 :table_schema              => Momomoto::Datatype::Text.new,
                 :table_name                => Momomoto::Datatype::Text.new,
                 :column_name               => Momomoto::Datatype::Text.new,
                 :ordinal_position          => Momomoto::Datatype::Integer.new,
                 :column_default            => Momomoto::Datatype::Text.new,
                 :is_nullable               => Momomoto::Datatype::Text.new,
                 :data_type                 => Momomoto::Datatype::Text.new,
                 :character_maximum_length  => Momomoto::Datatype::Integer.new,
                 :character_octet_length    => Momomoto::Datatype::Integer.new,
                 :numeric_precision         => Momomoto::Datatype::Integer.new,
                 :numeric_precision_radix   => Momomoto::Datatype::Integer.new,
                 :numeric_scale             => Momomoto::Datatype::Integer.new,
                 :datetime_precision        => Momomoto::Datatype::Integer.new,
                 :interval_type             => Momomoto::Datatype::Character_varying.new,
                 :interval_precision        => Momomoto::Datatype::Character_varying.new,
                 :character_set_catalog     => Momomoto::Datatype::Character_varying.new,
                 :character_set_schema      => Momomoto::Datatype::Character_varying.new,
                 :character_set_name        => Momomoto::Datatype::Character_varying.new,
                 :collation_catalog         => Momomoto::Datatype::Character_varying.new,
                 :collation_schema          => Momomoto::Datatype::Character_varying.new,
                 :collation_name            => Momomoto::Datatype::Character_varying.new,
                 :domain_catalog            => Momomoto::Datatype::Character_varying.new,
                 :domain_schema             => Momomoto::Datatype::Character_varying.new,
                 :domain_name               => Momomoto::Datatype::Character_varying.new,
                 :udt_catalog               => Momomoto::Datatype::Character_varying.new,
                 :udt_schema                => Momomoto::Datatype::Character_varying.new,
                 :udt_name                  => Momomoto::Datatype::Character_varying.new,
                 :scope_catalog             => Momomoto::Datatype::Character_varying.new,
                 :scope_schema              => Momomoto::Datatype::Character_varying.new,
                 :scope_name                => Momomoto::Datatype::Character_varying.new,
                 :maximum_cardinality       => Momomoto::Datatype::Integer.new,
                 :dtd_identifier            => Momomoto::Datatype::Character_varying.new,
                 :is_self_referencing       => Momomoto::Datatype::Character_varying.new
               } )
    end
  end
end

