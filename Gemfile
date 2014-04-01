source 'https://rubygems.org'

gemspec

group :docs do
  gem 'redcarpet',   ">= 2.1",   :platform => [:ruby]
  gem 'kramdown',                :platform => [:jruby]
end

# Gems for testing and coverage
group :test do
  gem 'simplecov',   ">= 0.5",   :platform => [:ruby_19],   :require => false
end

# Gems you would use if hacking on this gem (rather than with it)
group :support do
  # gem 'perftools.rb',            :platform => [:mri]
  #
  gem 'guard',       ">= 1.0",   :platform => [:ruby_19]
  gem 'guard-rspec', ">= 0.6",   :platform => [:ruby_19]
  gem 'guard-yard',              :platform => [:ruby_19]
  if RUBY_PLATFORM.include?('darwin')
    gem 'rb-fsevent', ">= 0.9",  :platform => [:ruby_19]
  end
  if ENV['GORILLIB_YARD']
    gem 'guard-livereload', ">= 1.0"
  end
end
