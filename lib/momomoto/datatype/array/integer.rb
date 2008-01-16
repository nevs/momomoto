module Momomoto
  module Datatype
    class Array

      # datatype for text arrays
      class Integer < Base

        def array_type
          "int"
        end

        def filter_get( value )
          value = super( value )
          if value.instance_of?( ::Array )
            value = value.map{|v| Integer(v)}
          end
          value
        end

      end

      Int4 = Integer

    end
  end
end

