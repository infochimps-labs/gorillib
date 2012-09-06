require 'bundler/setup' ; Bundler.require(:default, :development, :test)
require 'rspec/autorun'

if ENV['GORILLIB_COV']
  require 'simplecov'
  SimpleCov.start
end

GORILLIB_ROOT_DIR = File.expand_path(File.join(File.dirname(__FILE__),'..'))
def GORILLIB_ROOT_DIR *paths
  File.join(::GORILLIB_ROOT_DIR, *paths)
end

$LOAD_PATH.unshift(GORILLIB_ROOT_DIR('lib'))
$LOAD_PATH.unshift(GORILLIB_ROOT_DIR('spec/support'))

require_relative 'support/gorillib_test_helpers'
Dir[GORILLIB_ROOT_DIR('spec/support/matchers/*.rb')].each {|f| require f}
Dir[GORILLIB_ROOT_DIR('spec/support/shared_examples/*.rb')].each {|f| require f}

RSpec.configure do |config|
  include Gorillib::TestHelpers
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
