require 'spec_helper'
require 'gorillib/metaprogramming/delegation'

module One
  Constant1 = "Hello World"
  Constant2 = "What\'s up?"
end

class Ab
  include One
  Constant1 = "Hello World" # Will have different object id than One::Constant1
  Constant3 = "Goodbye World"
end

module Xy
  class Bc
    include One
  end
end

module Yz
  module Zy
    class Cd
      include One
    end
  end
end

Somewhere = Struct.new(:street, :city)

Someone   = Struct.new(:name, :place) do
  delegate :street, :city, :to_f, :to => :place
  delegate :upcase, :to => "place.city"
end

Invoice   = Struct.new(:client) do
  delegate :street, :city, :name, :to => :client, :prefix => true
  delegate :street, :city, :name, :to => :client, :prefix => :customer
end

Project   = Struct.new(:description, :person) do
  delegate :name, :to => :person, :allow_nil => true
  delegate :to_f, :to => :description, :allow_nil => true
end

Developer = Struct.new(:client) do
  delegate :name, :to => :client, :prefix => nil
end

Tester = Struct.new(:client) do
  delegate :name, :to => :client, :prefix => false
end

class Name
  delegate :upcase, :to => :@full_name

  def initialize(first, last)
    @full_name = "#{first} #{last}"
  end
end

# ===========================================================================
#
# Tests start

describe 'metaprogramming', :metaprogramming_spec => true do
  describe 'delegation' do
    before do
      @david = Someone.new("David", Somewhere.new("Paulina", "Chicago"))
    end

    it 'does not have an effect if already provided by another library.' unless ENV['QUIET_RSPEC']

    it 'delegates to methods' do
      @david.street.should == "Paulina"
      @david.city.should == "Chicago"
    end

    it 'delegates down hierarchy' do
      @david.upcase.should == "CHICAGO"
    end

    it 'delegates to instance variables' do
      david = Name.new("David", "Hansson")
      david.upcase.should == "DAVID HANSSON"
    end

    it 'raises with a missing delegation target' do
      lambda{ Name.send :delegate, :nowhere }.should raise_error(ArgumentError)
      lambda{ Name.send :delegate, :noplace, :tos => :hollywood }.should raise_error(ArgumentError)
    end

    it 'uses a prefix' do
      invoice = Invoice.new(@david)
      invoice.client_name.should   == "David"
      invoice.client_street.should == "Paulina"
      invoice.client_city.should   == "Chicago"
    end

    it 'accepts a custom prefix' do
      invoice = Invoice.new(@david)
      invoice.customer_name.should   == "David"
      invoice.customer_street.should == "Paulina"
      invoice.customer_city.should   == "Chicago"
    end

    it 'delegation prefix with nil or false' do
      Developer.new(@david).name.should == "David"
      Tester.new(@david).name.should    == "David"
    end

    it 'delegation prefix with instance variable' do
      lambda{
        Class.new do
          def initialize(client)
            @client = client
          end
          delegate :name, :address, :to => :@client, :prefix => true
        end
      }.should raise_error(ArgumentError)
    end

    it 'with allow_nil' do
      rails = Project.new("Rails", Someone.new("David"))
      rails.name.should == "David"
    end

    it 'with allow_nil, accepts a nil value' do
      rails = Project.new("Rails")
      rails.name.should be_nil
    end

    it 'with allow_nil, accepts a nil value and prefix' do
      Project.class_eval do
        delegate :name, :to => :person, :allow_nil => true, :prefix => true
      end
      rails = Project.new("Rails")
      rails.person_name.should be_nil
    end

    it 'without allow_nil, raises an error on nil vlaue' do
      david = Someone.new("David")
      lambda{ david.street }.should raise_error(RuntimeError)
    end

    it 'delegates to method that exists on nil' do
      nil_person = Someone.new(nil)
      nil_person.to_f.should == 0.0
    end

    it 'delegates to method that exists on nil when allowing nil' do
      nil_project = Project.new(nil)
      nil_project.to_f.should == 0.0
    end

    it 'does not raise error when removing singleton instance methods' do
      parent = Class.new do
        def self.parent_method; end
      end

      Class.new(parent) do
        class << self
          delegate :parent_method, :to => :superclass
        end
      end
    end
  end
end
