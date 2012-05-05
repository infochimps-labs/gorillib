require File.expand_path('../spec_helper', File.dirname(__FILE__))
#
require 'gorillib/metaprogramming/concern'
require 'gorillib/metaprogramming/remove_method'
require "gorillib/object/try_dup"
#
require 'gorillib/record/named_schema'
require 'gorillib/record'
require 'gorillib/record/validate'
require 'gorillib/record/errors'
require 'gorillib/record/field'
#
require 'record_test_helpers'

# describe Gorillib::Record do
#
#   describe 'Gorillib::RecordSchema' do
#     context ".meta_module" do
#       it "supplies the field-specific methods (`receive_foo`, etc)"
#       it "is injected right after the RecordType module"
#     end
#
#     context ".field" do
#       it "describes a property"
#       it "cannot override a parent's field"
#       context ":type option" do
#       end
#
#       # context "on a non-builder record," do
#       #   it "supplies a reader method #foo to call read_attribute(:foo)"
#       #   it_behaves_like "... with right visibility"
#       #   it "supplies a writer method #foo= to call write_attribute(:foo)"
#       #   it_behaves_like "... with right visibility"
#       # end
#     end
#
#     context ".fields" do
#       it 'is a hash of Gorillib::Record::Field objects'
#       it 'contains parent fields followed by own fields'
#     end
#
#     context '.receive' do
#       it 'creates a new instance using the given attributes'
#       it 'triggers the after_receive hooks'
#     end
#
#     context '.initialize' do
#       it 'recursively accepts the given attributes'
#       it 'calls super'
#     end
#
#   end
#
#   context '#receive'
#
#   context '#update_attributes'
#
# end
#
# shared_examples_for 'primitive attribute behavior' do
#   it '#read_attribute returns nil if unset'
#   it '#read_attribute returns the given value after a #write_attribute'
#   it 'after a #write_attribute, the attribute is set' do
#     unset.should == false
#   end
#   it "#write_attribute updates an existing value"
#   it "#unset_attribute clears the attribute"
#   it "#unset_attribute means the attribute is not set"
#   it "#unset_attribute works even if already unset"
# end
#
# describe "[mixin for attr_accessor strategy]" do
#   it 'read_attribute  gets an instance variable'
#   it 'write_attribute sets an instance variable'
#   it 'unset_attribute removes the instance variable'
#   it 'supplies primitive attribute behavior'
# end
#
# describe "[mixin for hash-access strategy]" do
#   it 'read_attribute  calls []'
#   it 'write_attribute calls []='
#   it 'unset_attribute calls #delete'
#   it 'supplies primitive attribute behavior'
# end
