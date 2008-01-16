module Momomoto
  module Datatype
    class Array

      # datatype for text arrays
      class Integer < Base

        # Escape and quote +input+ to be saved in database.
        # Returns 'NULL' if +input+ is nil or empty. Otherwise uses
        # Database#quote
        def escape( input )
          if input.nil?
            "NULL"
          elsif input.instance_of?( ::Array )
            "ARRAY[" + input.map{|m| Database.quote(m)}.join(',') + "]::int[]"
          else
            Database.quote(m)
          end
        end

      end

      Int4 = Integer

    end
  end
end

