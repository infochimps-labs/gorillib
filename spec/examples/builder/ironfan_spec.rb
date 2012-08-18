require 'spec_helper'

require 'gorillib/builder'

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Builder, :model_spec => true do
  before do
    require_relative '../../../examples/builder/ironfan.rb'
  end
  after(:each){   Gorillib::Test.nuke_constants ; Meta::Gorillib::Test.nuke_constants }

  def example_cluster
    Gorillib::Test.cluster
  end

  let(:ec_webnode  ){ fac = example_cluster.facet(:webnode); fac.cluster(example_cluster) ; fac }
  let(:ec_webnode_a){ svr = ec_webnode.server(:a);           svr.facet(ec_webnode)        ; svr }

  # it 'is awesome'

  context "collections get a {foo}_name accessor:" do
    it("facet.cluster_name"){ ec_webnode.cluster_name.should == :yellowhat }
    it("server.facet_name" ){ ec_webnode_a.facet_name.should == :webnode   }
  end

  context "collections get a `has_{foo}` tester:" do
    it("server.facet?"    ){ ec_webnode_a.facet?.should be_true }
    it("facet.has_server?"){ ec_webnode.should have_server(:a) }
  end
end
