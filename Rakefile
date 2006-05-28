
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
  t.test_files = FileList['test/test*.rb']
end

task :coverage => [:rcov] do
  sh "scp -r coverage pulsar:public_html"
end

