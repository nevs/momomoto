#!/usr/bin/env ruby

require 'rubygems'
require 'test/unit'
require 'lib/momomoto'

Momomoto::Database.instance.config(:database=>:test)

