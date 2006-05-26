
require 'rake/testtask'
require 'rcov/rcovtask'

task(:default => :test)

Rake::TestTask.new do | t |
  t.pattern = 'test/test_*.rb'
end

Rcov::RcovTask.new do | t |
  t.test_files = FileList['test/test*.rb']
end

