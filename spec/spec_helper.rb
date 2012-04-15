require 'rubygems' unless defined?(Gem)
# require 'spork'
require 'rspec'

GORILLIB_ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__),'..'))
def GORILLIB_ROOT_DIR *paths
  File.join(::GORILLIB_ROOT_DIR, *paths)
end

ENV['QUIET_RSPEC'] = 'please'

# Spork.prefork do # Must restart for changes to config / code from libraries loaded here
  $LOAD_PATH.unshift(GORILLIB_ROOT_DIR('lib'))
$LOAD_PATH.unshift(GORILLIB_ROOT_DIR('spec/support'))
require 'gorillib_test_helpers'
  Dir[GORILLIB_ROOT_DIR('spec/support/matchers/*.rb')].each {|f| require f}


RSpec.configure do |config|
  include Gorillib::TestHelpers
end
# end

# Spork.each_run do # This code will be run each time you run your specs.
#   RSpec.configure do |config|
#   end
# end
