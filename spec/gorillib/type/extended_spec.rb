require File.expand_path('../../spec_helper', File.dirname(__FILE__))

require 'gorillib/type/extended'
require 'gorillib/object/blank'

describe ::Long do
  it "is_a?(Integer)" do ::Long.should < ::Integer ; end
end

describe ::Double do
  it "is_a?(Float)" do ::Double.should < ::Float ; end
end

describe ::Binary do
  it "is_a?(String)" do ::Binary.should < ::String ; end
end

# describe ::Boolean, :model_spec => true do
#   let(:true_bool ){ ::Boolean.new(true)  }
#   let(:false_bool){ ::Boolean.new(false) }
#
#   def it_responds_same_as(test_obj, comparable, meth, *meth_args, &block)
#     test_obj.send(meth, *meth_args, &block).should == comparable.send(meth, *meth_args, &block)
#   end
#
#   def it_responds_with_same_contents(test_obj, comparable, meth, *meth_args, &block)
#     test_obj.send(meth, *meth_args, &block).sort.should == comparable.send(meth, *meth_args, &block).sort
#   end
#
#   it("has #class ::Boolean" ){ (true_bool.class).should == ::Boolean ; (false_bool.class).should == ::Boolean }
#
#   it "#is_a?(Boolean)"           do true_bool.should be_a(::Boolean)             ; false_bool.should be_a(::Boolean) ; end
#   it "#is_a?(True/False)"        do true_bool.should be_a(::TrueClass)           ; false_bool.should be_a(::FalseClass) ; end
#   it "#kind_of?(Boolean)"        do true_bool.should be_a_kind_of(::Boolean)     ; false_bool.should be_a_kind_of(::Boolean) ; end
#   it "#instance_of?(True/False)" do true_bool.should be_instance_of(::TrueClass) ; false_bool.should be_instance_of(::FalseClass) ; end
#
#   describe 'mimics true/false' do
#     [ :!, :to_s, :blank?, :frozen?, :nil?, :present?,
#     ].each do |meth|
#       it "##{meth}" do
#         it_responds_same_as(true_bool,  true,  meth)
#         it_responds_same_as(false_bool, false, meth)
#       end
#     end
#
#     [ :private_methods, :protected_methods, :singleton_methods,
#     ].each do |meth|
#       it "##{meth}" do
#         it_responds_with_same_contents(true_bool,  true,  meth)
#         it_responds_with_same_contents(false_bool, false, meth)
#       end
#     end
#     it "#methods"        do ( true.methods         - true_bool.methods  ).should be_empty ; end
#     it "#methods"        do ( false.methods        - false_bool.methods ).should be_empty ; end
#     it "#public_methods" do ( true.public_methods  - true_bool.public_methods  ).should be_empty ; end
#     it "#public_methods" do ( false.public_methods - false_bool.public_methods ).should be_empty ; end
#
#     it ".methods"          do (TrueClass.methods | [:true, :false, :new]).sort.should ==  Boolean.methods.sort ; end
#
#     { :!=           => [true, false, nil],
#       :!~           => [true, false, nil],
#       :&            => [true, false, nil],
#       :<=>          => [true, false, nil],
#       :==           => [true, false, nil],
#       :===          => [true, false, nil],
#       :=~           => [true, false, nil],
#       :^            => [true, false, nil],
#       :|            => [true, false, nil],
#       :eql?         => [true, false, nil],
#       :equal?       => [true, false, nil],
#       :instance_of? => [::TrueClass, ::FalseClass, ::Object],
#       :is_a?        => [::TrueClass, ::FalseClass, ::Object],
#       :kind_of?     => [::TrueClass, ::FalseClass, ::Object],
#     }.each do |meth, meth_args|
#       meth_args.each do |meth_arg|
#         it "##{meth}(#{meth_arg})" do
#           it_responds_same_as(true_bool,  true,  meth, meth_arg)
#           it_responds_same_as(false_bool, false, meth, meth_arg)
#         end
#       end
#     end
#
#   end
#
#   [ :==, :===, :eql?, :equal?, :<=> ].each do |meth|
#     it "Boolean.true #{meth} itself and true" do
#       true_bool.send(meth,  true_bool     ).should be_true
#       true_bool.send(meth,  Boolean.true  ).should be_true
#       true_bool.send(meth,  true          ).should be_true
#       true_bool.send(meth,  false_bool    ).should be_false
#       true_bool.send(meth,  Boolean.false ).should be_false
#       true_bool.send(meth,  false         ).should be_false
#       true_bool.send(meth,  0             ).should be_false
#     end
#     it "Boolean.false #{meth} itself and false" do
#       false_bool.send(meth, false_bool    ).should be_true
#       false_bool.send(meth, Boolean.false ).should be_true
#       false_bool.send(meth, false         ).should be_true
#       false_bool.send(meth, true_bool     ).should be_false
#       false_bool.send(meth, Boolean.true  ).should be_false
#       false_bool.send(meth, true          ).should be_false
#       false_bool.send(meth, 0             ).should be_false
#     end
#     it "!=" do
#       (true_bool  != true         ).should be_false ; (true_bool  != false        ).should be_true
#       (true_bool  != true_bool    ).should be_false ; (true_bool  != false_bool   ).should be_true
#       (true_bool  != Boolean.true ).should be_false ; (true_bool  != Boolean.false).should be_true
#       (true_bool  != 0            ).should be_true  ; (true_bool  != "true"       ).should be_true
#       (false_bool != false        ).should be_false ; (false_bool != true         ).should be_true
#       (false_bool != false_bool   ).should be_false ; (false_bool != true_bool    ).should be_true
#       (false_bool != Boolean.false).should be_false ; (false_bool != Boolean.true ).should be_true
#       (false_bool != 0            ).should be_true  ; (false_bool  != "true"      ).should be_true
#     end
#     it "!~" do
#       (true_bool !~ true        ).should be_true
#       (true_bool !~ true_bool   ).should be_true
#       (true_bool !~ Boolean.true).should be_true
#     end
#   end
# end
