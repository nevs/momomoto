#!/usr/bin/env ruby

require 'test/unit'
require 'lib/momomoto'

Momomoto::Database.instance.config(:database=>:test)

