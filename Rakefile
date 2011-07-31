require 'rubygems' unless defined?(Gem)
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name        = "gorillib"
  gem.homepage    = "http://infochimps.com/labs"
  gem.license     = "MIT"
  gem.summary     = %Q{include only what you need. No dependencies, no creep}
  gem.description = %Q{Gorillib: infochimps lightweight subset of ruby convenience methods}
  gem.email       = "coders@infochimps.org"
  gem.authors     = ["Infochimps"]

  gem.add_development_dependency 'bundler', "~> 1.0.12"
  gem.add_development_dependency 'yard',    "~> 0.6.7"
  gem.add_development_dependency 'jeweler', "~> 1.5.2"
  gem.add_development_dependency 'rspec',   "~> 2.5.0"
  gem.add_development_dependency 'rcov',    ">= 0.9.9"
  gem.add_development_dependency 'spork',   "~> 0.9.0.rc5"
  gem.add_development_dependency 'watchr'

  ignores = File.readlines(".gitignore").grep(/^[^#]\S+/).map{|s| s.chomp }
  dotfiles = [".gemtest", ".gitignore", ".rspec", ".yardopts"]
  gem.files = dotfiles + Dir["**/*"].
    reject{|f| f =~ %r{^(vendor|coverage)/} }.
    reject{|f| File.directory?(f) }.
    reject{|f| ignores.any?{|i| File.fnmatch(i, f) || File.fnmatch(i+'/**/*', f) || File.fnmatch(i+'/*', f) } }
  gem.test_files = gem.files.grep(/^spec\//)
  gem.require_paths = ['lib']
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = %w[ --exclude .rvm --no-comments --text-summary]
end

task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new

# App-specific tasks
Dir[File.dirname(__FILE__)+'/lib/tasks/**/*.rake'].sort.each{|f| load f }
