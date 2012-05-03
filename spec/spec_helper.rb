require 'rubygems' unless defined?(Gem)
require 'rspec'

GORILLIB_ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__),'..'))
def GORILLIB_ROOT_DIR *paths
  File.join(::GORILLIB_ROOT_DIR, *paths)
end

ENV['QUIET_RSPEC'] = 'please'

$LOAD_PATH.unshift(GORILLIB_ROOT_DIR('lib'))
$LOAD_PATH.unshift(GORILLIB_ROOT_DIR('spec/support'))
require 'gorillib_test_helpers'
Dir[GORILLIB_ROOT_DIR('spec/support/matchers/*.rb')].each {|f| require f}

RSpec.configure do |config|
  include Gorillib::TestHelpers
end
