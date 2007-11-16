
require 'rake'

Gem::Specification.new do | s |
  s.name = "momomoto"
  s.homepage = "http://pentabarf.org/Momomoto"
  s.version = '0.1.12'

  s.author = "Sven Klemm"
  s.email = "sven@c3d2.de"

  s.summary = "Momomoto is an object relational mapper for PostgreSQL."
  s.description = <<-EOF
    Momomoto is an object relational mapper for PostgreSQL.
  EOF

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.2'
  s.add_dependency('ruby-postgres', '>= 0.7.1.2006.04.06')
  s.requirements << 'PostgreSQL 8.1.x or greater'
  s.autorequire = "momomoto"
  s.has_rdoc = true
  s.date = Time.now
  s.files = FileList['lib/**/*.rb', 'sql/**/*.sql', 'test/**/*.rb', 'test/**/*.sql', '[A-Z]*'].to_a
end

