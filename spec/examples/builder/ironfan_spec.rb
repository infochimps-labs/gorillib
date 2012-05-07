require File.expand_path('../../spec_helper', File.dirname(__FILE__))
# related libs
require 'gorillib/record'
require 'gorillib/record/field'
require 'gorillib/record/defaults'
# libs under test
require 'gorillib/builder'
require 'gorillib/builder/field'
require 'gorillib/string/simple_inflector'
# testing helpers

load GORILLIB_ROOT_DIR('examples/builder/ironfan.rb')

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Builder, :record_spec => true do
  after(:each){   Gorillib::Test.nuke_constants ; Meta::Gorillib::Test.nuke_constants }
  def example_cluster
    Gorillib::Test.cluster
  end
  
  it 'is' do
    p example_cluster
    puts example_cluster.facets.inspect
    puts example_cluster.facets.inspect(false)
    webnode = example_cluster.facet(:webnode)
    svr = webnode.servers.to_a.first
    p svr

    p webnode.cluster_name
    p svr.facet_name
  end

end
