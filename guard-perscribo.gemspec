# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard-perscribo/version'

Gem::Specification.new do |spec|
  spec.name          = 'guard-perscribo'
  spec.version       = GuardPerscribo::VERSION
  spec.authors       = ['Adam Eberlin']
  spec.email         = ['ae@adameberlin.com']
  spec.summary       = 'Perscribo mixins for Guard development environments.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/arkbot/guard-perscribo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  
  spec.add_dependency 'activesupport'
  spec.add_dependency 'colorize'
  spec.add_dependency 'guard', '~> 2.6.1'
  spec.add_dependency 'perscribo'
end
