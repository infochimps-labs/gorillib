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

load GORILLIB_ROOT_DIR('examples/builder/workflow.rb')

module WukongTest       ; end
module Meta::WukongTest ; end

describe Gorillib::Builder, :record_spec => true do
  after(:each){   WukongTest.nuke_constants ; Meta::WukongTest.nuke_constants }
  def example_workflow
    WukongTest.workflow
  end

  let(:ec_webnode  ){ example_cluster.facet(:webnode) }
  let(:ec_webnode_a){ ec_webnode.server(:a) }

  it 'is awesome' do
    p example_workflow
  end

  # context "collections get a {foo}_name accessor:" do
  #   it("facet.cluster_name"){ ec_webnode.cluster_name.should == :yellowhat }
  #   it("server.facet_name" ){ ec_webnode_a.facet_name.should == :webnode   }
  # end
  #
  # context "collections get a `has_{foo}` tester:" do
  #   it("server.facet?"    ){ ec_webnode_a.facet?.should be_true }
  #   it("facet.has_server?"){ ec_webnode.should have_server(:a) }
  # end
end
