require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/slice'

describe Hash, "only" do
  before do
    @hash = { :one => 'ONE', 'two' => 'TWO', 3 => 'THREE', 4 => nil }
  end

  it "should return a hash with only the given key(s)" do
    @hash.only(:not_in_there).should == {}
    @hash.only(4).should == {4 => nil}
    @hash.only(:one).should == { :one => 'ONE' }
    @hash.only(:one, 3).should == { :one => 'ONE', 3 => 'THREE' }
  end
end


describe Hash, "except" do
  before do
    @hash = { :one => 'ONE', 'two' => 'TWO', 3 => 'THREE' }
  end

  it "should return a hash without only the given key(s)" do
    @hash.except(:one).should == { 'two' => 'TWO', 3 => 'THREE' }
    @hash.except(:one, 3).should == { 'two' => 'TWO' }
  end
end

# describe Hash, 'to_params' do
#   {
#     { "foo" => "bar", "baz" => "bat" } => "foo=bar&baz=bat",
#     { "foo" => [ "bar", "baz" ] } => "foo%5B%5D=bar&foo%5B%5D=baz",
#     { "foo" => [ {"bar" => "1"}, {"bar" => 2} ] } => "foo%5B%5D%5Bbar%5D=1&foo%5B%5D%5Bbar%5D=2",
#     { "foo" => { "bar" => [ {"baz" => 1}, {"baz" => "2"}  ] } } => "foo%5Bbar%5D%5B%5D%5Bbaz%5D=1&foo%5Bbar%5D%5B%5D%5Bbaz%5D=2",
#     { "foo" => {"1" => "bar", "2" => "baz"} } => "foo%5B1%5D=bar&foo%5B2%5D=baz"
#   }.each do |hash, params|
#     it "should covert hash: #{hash.inspect} to params: #{params.inspect}" do
#       hash.to_params.split('&').sort.should == params.split('&').sort
#     end
#   end
#
#   it 'should not leave a trailing &' do
#     { :name => 'Bob', :address => { :street => '111 Ruby Ave.', :city => 'Ruby Central', :phones => ['111-111-1111', '222-222-2222'] } }.to_params.should_not match(/&$/)
#   end
#
#   it 'should encode query keys' do
#     { 'First & Last' => 'Alice Smith' }.to_params.should == "First%20%26%20Last=Alice%20Smith"
#   end
#
#   it 'should encode query values' do
#     { :name => 'Alice & Bob' }.to_params.should == "name=Alice%20%26%20Bob"
#   end
# end
#
# describe Hash, 'to_mash' do
#   before :each do
#     @hash = Hash.new(10)
#   end
#
#   it "copies default Hash value to Mash" do
#     @mash = @hash.to_mash
#     @mash[:merb].should == 10
#   end
# end
