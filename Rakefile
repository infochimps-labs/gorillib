require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.setup(:default, :development)
require 'rake'

task :default => :rspec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:rspec) do |spec|
  Bundler.setup(:default, :development, :test)
  spec.pattern = 'spec/**/*_spec.rb'
end

desc "Run RSpec with code coverage"
task :cov do
  ENV['GORILLIB_COV'] = "yep"
  Rake::Task[:rspec].execute
end

require 'yard'
YARD::Rake::YardocTask.new do
  Bundler.setup(:default, :development, :docs)
end

# <<<<<<< HEAD
require 'jeweler'
Jeweler::Tasks.new do |gem|
  Bundler.setup(:default, :development, :test)
  gem.name        = 'gorillib'
  gem.homepage    = 'https://github.com/infochimps-labs/gorillib'
  gem.license     = 'Apache 2.0'
  gem.email       = 'coders@infochimps.org'
  gem.authors     = ['Infochimps']

  gem.summary     = %Q{include only what you need. No dependencies, no creep}
  gem.description = %Q{Gorillib: infochimps lightweight subset of ruby convenience methods}

  ignores = File.readlines(".gitignore").grep(/^[^#]\S+/).map{|s| s.chomp }
  dotfiles = [".gemtest", ".gitignore", ".rspec", ".yardopts"]
  gem.files = dotfiles + Dir["**/*"].
    reject{|f| f =~ %r{^(vendor|coverage|old|away)/} }.
    reject{|f| File.directory?(f) }.
    reject{|f| ignores.any?{|i| File.fnmatch(i, f) || File.fnmatch(i+'/**/*', f) || File.fnmatch(i+'/*', f) } }
  gem.test_files = gem.files.grep(/^spec\//)
  gem.extra_rdoc_files = [gem.files.grep(/^notes\//), gem.files.grep(/\.md$/)].flatten.uniq
  gem.require_paths = ['lib']
end
Jeweler::RubygemsDotOrgTasks.new
# =======
# Bundler::GemHelper.install_tasks
# 
# # require 'jeweler'
# # Jeweler::Tasks.new do |gem|
# #   # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
# #   gem.name        = "gorillib"
# #   gem.homepage    = "http://infochimps.com/labs"
# #   gem.license     = "MIT"
# #   gem.summary     = %Q{include only what you need. No dependencies, no creep}
# #   gem.description = %Q{Gorillib: infochimps lightweight subset of ruby convenience methods}
# #   gem.email       = "coders@infochimps.org"
# #   gem.authors     = ["Infochimps"]
# 
# #   ignores = File.readlines(".gitignore").grep(/^[^#]\S+/).map{|s| s.chomp }
# #   dotfiles = [".gemtest", ".gitignore", ".rspec", ".yardopts"]
# #   gem.files = dotfiles + Dir["**/*"].
# #     reject{|f| f =~ %r{^(vendor|coverage)/} }.
# #     reject{|f| File.directory?(f) }.
# #     reject{|f| ignores.any?{|i| File.fnmatch(i, f) || File.fnmatch(i+'/**/*', f) || File.fnmatch(i+'/*', f) } }
# #   gem.test_files = gem.files.grep(/^spec\//)
# #   gem.require_paths = ['lib']
# # end
# # Jeweler::RubygemsDotOrgTasks.new
# 
# require 'rspec/core'
# require 'rspec/core/rake_task'
# RSpec::Core::RakeTask.new(:spec) do |spec|
#   Bundler.setup(:default, :development, :test)
#   spec.pattern = FileList['spec/**/*_spec.rb']
# end
# 
# # RSpec::Core::RakeTask.new(:rcov) do |spec|
# #   Bundler.setup(:default, :development, :test)
# #   spec.pattern = 'spec/**/*_spec.rb'
# #   spec.rcov = true
# #   spec.rcov_opts = %w[ --exclude .rvm --no-comments --text-summary]
# # end
# 
# require 'yard'
# YARD::Rake::YardocTask.new do
#   Bundler.setup(:default, :development, :docs)
# end
# 
# # App-specific tasks
# Dir[File.dirname(__FILE__)+'/lib/tasks/**/*.rake'].sort.each{|f| load f }
# 
# task :default => :spec
# >>>>>>> 0e8b5729b159c7aa8c596c4d5bc1757f7562e71b
