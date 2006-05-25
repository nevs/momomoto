#!/usr/bin/env ruby

$LOAD_PATH.unshift( File.join( File.dirname(__FILE__), 'lib' ))

require 'benchmark'
require 'momomoto'
require 'rubygems'
require 'active_record'

include Benchmark

GC.disable

QUERY_REPEAT = 10
ITERATION_REPEAT = 10

puts "==Momomoto==========================================================================="
Momomoto::Database.instance.config('database'=>'pentabarf','username'=>'pentabarf')
Momomoto::Database.instance.connect
Benchmark.benchmark(" "*40 + CAPTION, 40, FMTSTR, ">total:", ">avg:") do | b |
  a = nil
  times = []  
  times << b.report("querying the first time") do
    a = Momomoto::Information_schema::Columns.select
  end

  times << b.report("querying #{QUERY_REPEAT} times") do
    QUERY_REPEAT.times do 
      a = Momomoto::Information_schema::Columns.select
    end
  end

  times << b.report("iterating #{ITERATION_REPEAT} times over the resultset") do
    ITERATION_REPEAT.times do a.each do | row | temp = row end end
  end

  repeat = ITERATION_REPEAT * a.length
  times << b.report("accessing an element #{repeat} times") do
    a = a[0]
    repeat.times do 
      a.table_catalog
    end
  end

  times << b.report("querying #{QUERY_REPEAT} times for subset") do
    QUERY_REPEAT.times do 
      a = Momomoto::Information_schema::Columns.select({:table_name => 'columns'})
    end
  end
  total = times.inject do | memo, time | memo += time end
  [ total , total / times.length ]
end

puts "==ActiveRecord======================================================================="

ActiveRecord::Base.connection = {'adapter'=>'postgresql','host'=>'localhost', 'database' => 'pentabarf', 'username' => 'pentabarf'}

class Columns < ActiveRecord::Base
  set_table_name 'information_schema.columns'
end

Benchmark.benchmark(" "*40 + CAPTION, 40, FMTSTR, ">total:", ">avg:") do | b |
  a = nil
  times = []  
  times << b.report("querying the first time") do
    a = Columns.find_all
  end
  
  times << b.report("querying #{QUERY_REPEAT} times") do
    QUERY_REPEAT.times do
      a = Columns.find_all
    end
  end

  times << b.report("iterating #{ITERATION_REPEAT} times over the resultset") do
    ITERATION_REPEAT.times do a.each do | row | temp = row end end
  end

  repeat = ITERATION_REPEAT * a.length
  times << b.report("accessing an element #{repeat} times") do
    a = a[0]
    repeat.times do 
      a.table_catalog
    end
  end

  times << b.report("querying #{QUERY_REPEAT} times for subset") do
    QUERY_REPEAT.times do 
      a = Columns.find_all_by_table_name('columns')
    end
  end

  total = times.inject do | memo, time | memo += time end
  [ total , total / times.length ]
end

puts "==Native SQL========================================================================="

conn = PGconn.connect('localhost', 5432,nil, nil,'pentabarf', 'pentabarf')

Benchmark.benchmark(" "*40 + CAPTION, 40, FMTSTR, ">total:", ">avg:") do | b |
  a = nil
  times = []  
  times << b.report("querying the first time") do
    a = conn.exec("SELECT * FROM information_schema.columns;").entries
  end
  
  times << b.report("querying #{QUERY_REPEAT} times") do
    QUERY_REPEAT.times do
      a = conn.exec("SELECT * FROM information_schema.columns;").entries
    end
  end
    
  times << b.report("iterating #{ITERATION_REPEAT} times over the resultset") do
    ITERATION_REPEAT.times do a.each do | row | temp = row end end
  end

  repeat = ITERATION_REPEAT * a.length
  times << b.report("accessing an element #{repeat} times") do
    a = a[0]
    repeat.times do 
      a[0]
    end
  end

  times << b.report("querying #{QUERY_REPEAT} times for subset") do
    QUERY_REPEAT.times do 
      a = conn.exec("SELECT table_catalog, table_schema, table_name, column_name, ordinal_position, column_default, is_nullable, data_type, character_maximum_length, character_octet_length, numeric_precision, numeric_precision_radix, numeric_scale, datetime_precision, interval_type, interval_precision, character_set_catalog, character_set_schema, character_set_name, collation_catalog, collation_schema, collation_name, domain_catalog, domain_schema, domain_name, udt_catalog, udt_schema, udt_name, scope_catalog, scope_schema, scope_name, maximum_cardinality, dtd_identifier, is_self_referencing FROM information_schema.columns WHERE table_name = 'columns';").entries
      
    end
  end

  total = times.inject do | memo, time | memo += time end
  [ total , total / times.length ]
end

