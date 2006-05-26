
module Momomoto

  # this class implements the join functionality it is an abstract class
  # it must not be used directly but you should inherit from this class
  class Join < Base
 
    # constructor of the join class
    # base_table is the base table of the join
    # join_rules is an array of Hashes consisting of the table to join as key
    # and an symbol or an array of symbols on which fields to join the table
    # Example: Momomoto::Join.new(Event, {Event_Person=>:event_id},{Person=>:person_id})
    #          results in SELECT * FROM event INNER JOIN event_person USING (event_id) INNER JOIN Person USING(person_id)
    # if you leave out the eclipit braces to mark the hash you may get 
    # unexpected results because of the undefined order of hashs         
    def initialize( base_table, *join_rules )
      @base_table = base_table
      @join_rules = join_rules

      metaclass.instance_eval do
        define_method( base_table.table_name ) do base_table end
      end
      join_rules.each do | rule |
        rule.keys.each do | table, join_columns |
          metaclass.instance_eval do
            define_method( table.table_name ) do table end
          end
        end
      end
    end

    def metaclass # :nodoc:
      class << self; self; end
    end

    def select( conditions = {}, options = {} )
      sql = "SELECT " + self.class.columns.keys.map{ | field | '"' + field.to_s + '"' }.join( "," ) + " FROM "
      sql += self.class.schema_name + '.' if self.class.schema_name
      sql += self.class.base_table_name
      self.class.join.each do | rules |
        rules.each do | table_name, fields |
          fields = fields.class === Array ? fields : [fields]
          sql += " INNER JOIN #{table_name} USING(#{fields.join(', ')})"
        end
      end
      sql += compile_where( conditions )
      sql += " LIMIT #{options[:limit]}" if options[:limit]
      sql += " ORDER BY #{options[:order]}" if options[:order]
      @data = []
      self.class.database.execute( sql ).each do | row |
        @data << self.class.const_get(:Row).new( self, row )
      end
      self
    end

  end

end

