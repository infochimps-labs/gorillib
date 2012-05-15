require 'spec_helper'

# related libs
require 'gorillib/string/simple_inflector'
require 'gorillib/model'
require 'gorillib/model/field'
require 'gorillib/model/defaults'
# libs under test
require 'gorillib/builder'
require 'gorillib/builder/field'
require 'gorillib/collection/has_collection'
# testing helpers

load GORILLIB_ROOT_DIR('examples/builder/workflow.rb')

module WukongTest       ; end
module Meta::WukongTest ; end

# describe Gorillib::Builder, :example_spec => true do
#   after(:each){   WukongTest.nuke_constants ; Meta::WukongTest.nuke_constants }
#   def example_workflow
#     WukongTest.workflow(:cherry_pie)
#   end
#
#   it 'is awesome' do
#     # p WukongTest::Kitchen.utensils
#     # p WukongTest::Kitchen.ingredients
#
#     p example_workflow
#     example_workflow.stages.to_a.each do |stage|
#       p stage
#       p stage.stages
#     end
#
#     puts
#     puts example_workflow.tree
#   end
#
#   # context "collections get a {foo}_name accessor:" do
#   #   it("facet.cluster_name"){ ec_webnode.cluster_name.should == :yellowhat }
#   #   it("server.facet_name" ){ ec_webnode_a.facet_name.should == :webnode   }
#   # end
#   #
#   # context "collections get a `has_{foo}` tester:" do
#   #   it("server.facet?"    ){ ec_webnode_a.facet?.should be_true }
#   #   it("facet.has_server?"){ ec_webnode.should have_server(:a) }
#   # end
# end
