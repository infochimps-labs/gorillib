require 'rubygems' unless defined?(Gem)
require 'spork'
require 'rspec'

Spork.prefork do
  # You'll need to restart for changes to configuration or code from libraries loaded here

  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

  RSpec.configure do |config|
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
