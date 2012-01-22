require File.expand_path('../lib/clouddns/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "rackspace-clouddns"
  s.version     = CloudDns::VERSION.dup
  s.summary     = "Rackspace CloudDNS API Wrapper"
  s.description = "Ruby library to consume Rackspace CloudDNS API"
  s.homepage    = "http://github.com/sosedoff/rackspace-clouddns"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec',              '~> 2.6'
  s.add_development_dependency 'webmock',            '~> 1.6'
  s.add_development_dependency 'simplecov',          '~> 0.5'
  
  s.add_runtime_dependency     'hashie',             '~> 1.0'
  s.add_runtime_dependency     'faraday',            '~> 0.7'
  s.add_runtime_dependency     'faraday_middleware', '~> 0.7'
  s.add_runtime_dependency     'multi_json',         '~> 1.0'
  
  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths      = ["lib"]
  s.default_executable = 'clouddns'
end