# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/logjam/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-logjam'
  spec.version       = Rack::Logjam::VERSION
  spec.authors       = ['Jason Harrelson', 'Nils Jonsson']
  spec.email         = ['ninja.loss@gmail.com']
  spec.summary       = 'Logs helpful HTTP information on Rack requests.'
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) do |f|
                         File.basename f
                       end
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'jsonpath', '~> 0.5'
  spec.add_dependency 'multi_json'
  spec.add_dependency 'nokogiri'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
