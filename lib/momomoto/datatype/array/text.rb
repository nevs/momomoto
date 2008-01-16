module Momomoto
  module Datatype
    class Array

      # datatype for text arrays
      class Text < Base

        # Escape and quote +input+ to be saved in database.
        # Returns 'NULL' if +input+ is nil or empty. Otherwise uses
        # Database#quote
        def escape( input )
          if input.nil?
            "NULL"
          elsif input.instance_of?( ::Array )
            "ARRAY[" + input.map{|m| Database.quote(m)}.join(',') + "]::text[]"
          else
            Database.quote(m)
          end
        end

      end
    end
  end
end

