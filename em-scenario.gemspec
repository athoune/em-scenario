Gem::Specification.new do |s|
  s.name             = "em-scenario"
  s.version          = "0.0.5"
  s.date             = Time.now.utc.strftime("%Y-%m-%d")
  s.homepage         = "http://github.com/athoune/em-scenario"
  s.authors          = "Mathieu Lecarme"
  s.email            = "mathieu@garambrogne.net"
  s.description      = "Handling simpler story with event machine's callback"
  s.summary          = s.description
  s.extra_rdoc_files = %w(README.md)
  s.files            = Dir["", "README.md", "Gemfile", "lib/**/*.rb"]
  s.require_paths    = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.add_dependency "eventmachine", "1.0.0.beta.3"
  s.add_development_dependency "minitest", "~>2.0"
  s.add_development_dependency "rake"
end
