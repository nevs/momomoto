#!/usr/bin/env ruby

require 'rubygems'
require 'test/unit'
require 'lib/momomoto'

Momomoto::Database.instance.config(:database=>:test)

class Test::Unit::TestCase

  undef_method( :setup )
  undef_method( :teardown )

  def setup
    Momomoto::Database.instance.connect
  end

  def teardown
    Momomoto::Database.instance.disconnect
  end

end

