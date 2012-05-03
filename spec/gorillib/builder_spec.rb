require File.expand_path('../spec_helper', File.dirname(__FILE__))

# describe "[builder gettersettter pattern]" do
#
#   it "supplies a gettersettter method #foo, and no method #foo="
#   it_behaves_like "... a gettersetter method"
#
#   shared_examples_for "a simple gettersettter method" do
#     it "with no arg, reads the current value"
#     it "with an argument, writes the new value"
#     it "with a nil arg, `write_attribute`s the value to nil"
#     it "returns the updated value"
#   end
#
#   shared_examples_for "a named collection gettersettter method" do
#     it "example: utensil(:spork, :tines => 3){ color :black } creates or updates a utensil named :spork with 3 tines, color black."
#     shared_examples_for 'collection member' do
#       it "executes a supplied block with no arity (`utensil(:spork){     ... }`) in the context of the collection member"
#       it "executes a supplied block with arity 1  (`utensil(:spork){ |u| ... }`) in the current context, passing the member as the block param"
#       it "does not execute a block if no block is supplied"
#       it "returns the collection member"
#     end
#     context "if absent" do
#       it "creates a new member"
#       it "with the given name"
#       it "accepts an attribute hash on behalf of the new member"
#       it "has behavior for collection member"
#     end
#     context "if exists" do
#       it "retrieves a named record"
#       it "accepts an attribute hash to update the member"
#       it "has behavior for collection member"
#     end
#   end
# end
