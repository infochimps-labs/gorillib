source "http://rubygems.org"

gem   'multi_json',  ">= 1.1"

# Only gems that you want listed as development dependencies in the gemspec
group :development do
  gem 'bundler',     "~> 1.1"
  gem 'rake'
  gem 'rspec',       "~> 2.8"
  gem 'yard',        ">= 0.7"
  #
  gem 'redcarpet',   ">= 2.1"
  gem 'oj',          ">= 1.2", :platform => :ruby
  gem 'json',                  :platform => :jruby
end

# Gems you would use if hacking on this gem (rather than with it)
group :support do
  gem 'jeweler',     ">= 1.6"
  gem 'pry'
end

# Gems for testing and coverage
group :test do
  gem 'simplecov',   ">= 0.5", :platform => :ruby_19
  #
  gem 'guard',       ">= 1.0"
  gem 'guard-rspec', ">= 0.6"
  gem 'guard-yard',   "~> 2.0"

  if ENV['GORILLIB_YARD']
    gem 'guard-livereload', ">= 1.0"
  end
  #
  if RUBY_PLATFORM.include?('darwin')
    gem 'rb-fsevent', ">= 0.9"
  end
end
