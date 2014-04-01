# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gorillib/version'

Gem::Specification.new do |gem|
  gem.name          = 'gorillib'
  gem.version       = Gorillib::VERSION
  gem.authors       = %w[ Infochimps ]
  gem.email         = 'coders@infochimps.com'
  gem.homepage      = 'http://infochimps.com/labs'
  gem.licenses      = ['Apache 2.0']
  gem.summary       = 'include only what you need. No dependencies, no creep'
  gem.description   = 'Gorillib: infochimps lightweight subset of ruby convenience methods'
  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = %w[ lib ]
    
  if gem.respond_to? :specification_version then
    gem.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0')
      gem.add_runtime_dependency('multi_json', [">= 1.1"])
      gem.add_runtime_dependency('configliere', [">= 0.4.13"])
    else
      gem.add_dependency('multi_json', [">= 1.1"])
      gem.add_dependency('configliere', [">= 0.4.13"])
    end
  else
    gem.add_dependency('multi_json', [">= 1.1"])
    gem.add_dependency('configliere', [">= 0.4.13"])
  end

  gem.add_development_dependency('bundler', ["~> 1.1"])
  gem.add_development_dependency('pry', [">= 0"])
  gem.add_development_dependency('rspec', [">= 2.8"])
  gem.add_development_dependency('rake', [">= 0"])
  gem.add_development_dependency('yard', [">= 0.7"])
end
