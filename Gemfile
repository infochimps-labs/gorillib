source "http://rubygems.org"

gem "json"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem 'bundler',   "~> 1"
  gem 'jeweler',   "~> 1.6"
  gem 'rspec',     "~> 2.5"
  gem 'yard',      "~> 0.6"
end

group :docs do
end

group :test do
  gem 'spork',     ">= 0.9.0", :platform => :mri
  gem 'rcov',      ">= 0.9.9", :platform => :ruby_18
  gem 'simplecov', ">= 0.5",   :platform => :ruby_19
  #
  # gem 'ruby_gntp'
  gem 'guard',         "~> 1"
  gem 'guard-rspec'
  gem 'guard-yard'
end
