# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = 'keycdn-api'
  s.version     = '0.1'

  s.summary     = "KeyCDN API"
  s.description = "A simple wrapper for the KeyCDN API functionality"

  s.authors     = ["Nikolay Nikolov"]
  s.email       = 'npn@elsix.bg'
  s.license       = 'MIT'

  s.files       = Dir.glob("lib/**/*.rb")
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'excon', '~>0.45'
  s.add_runtime_dependency 'multi_json', '~>1.8'
end
