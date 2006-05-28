
require 'rake/testtask'
require 'rcov/rcovtask'

task(:default => :test)

Rake::TestTask.new do | t |
  t.pattern = 'test/test_*.rb'
  t.ruby_opts << '-I.'
  t.ruby_opts << '-rtest_setup'
  t.verbose = false
  t.warning = true
end

Rcov::RcovTask.new do | t |
  t.test_files = FileList['test/test*.rb'].unshift( 'test_setup.rb' )
end

desc "copy the coverage information to pentabarf.org"
task :coverage => [:rcov] do | t |
  sh "scp -r coverage pulsar:public_html"
end

desc "run benchmark"
task( :bench ) do | t |
  sh "ruby benchmark.rb"
end

