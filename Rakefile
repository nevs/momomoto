
require 'rake/testtask'

task(:default => :test)

Rake::TestTask.new do | t |
  t.pattern = 'test/test_*.rb'
  t.ruby_opts << '-I.'
  t.ruby_opts << '-rtest_setup'
#  t.options = '-rgtk2'
  t.verbose = false
  t.warning = true
end

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do | t |
    t.libs << 'test_setup.rb'
#    t.rcov_opts << '--xrefs'
    t.rcov_opts << '--comments'
#    t.rcov_opts << '--profile'
    t.rcov_opts << '-x test_setup.rb'
    t.rcov_opts << '-x rcov.rb'
    t.test_files = FileList['test/test*.rb'].unshift( 'test_setup.rb' )
  end

rescue LoadError
end

desc "create documentation for ri"
task :doc do
  sh "rdoc -r lib"
end

desc "run benchmark"
task( :bench ) do | t |
  sh "ruby benchmark.rb"
end

