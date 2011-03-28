require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/delegation'

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

class ModuleTest < Test::Unit::TestCase
  def setup
    @david = Someone.new("David", Somewhere.new("Paulina", "Chicago"))
  end

  def test_delegation_to_methods
    assert_equal "Paulina", @david.street
    assert_equal "Chicago", @david.city
  end

  def test_delegation_down_hierarchy
    assert_equal "CHICAGO", @david.upcase
  end

  def test_delegation_to_instance_variable
    david = Name.new("David", "Hansson")
    assert_equal "DAVID HANSSON", david.upcase
  end

  def test_missing_delegation_target
    assert_raise(ArgumentError) do
      Name.send :delegate, :nowhere
    end
    assert_raise(ArgumentError) do
      Name.send :delegate, :noplace, :tos => :hollywood
    end
  end

  def test_delegation_prefix
    invoice = Invoice.new(@david)
    assert_equal invoice.client_name, "David"
    assert_equal invoice.client_street, "Paulina"
    assert_equal invoice.client_city, "Chicago"
  end

  def test_delegation_custom_prefix
    invoice = Invoice.new(@david)
    assert_equal invoice.customer_name, "David"
    assert_equal invoice.customer_street, "Paulina"
    assert_equal invoice.customer_city, "Chicago"
  end

  def test_delegation_prefix_with_nil_or_false
    assert_equal Developer.new(@david).name, "David"
    assert_equal Tester.new(@david).name, "David"
  end

  def test_delegation_prefix_with_instance_variable
    assert_raise ArgumentError do
      Class.new do
        def initialize(client)
          @client = client
        end
        delegate :name, :address, :to => :@client, :prefix => true
      end
    end
  end

  def test_delegation_with_allow_nil
    rails = Project.new("Rails", Someone.new("David"))
    assert_equal rails.name, "David"
  end

  def test_delegation_with_allow_nil_and_nil_value
    rails = Project.new("Rails")
    assert_nil rails.name
  end

  def test_delegation_with_allow_nil_and_nil_value_and_prefix
    Project.class_eval do
      delegate :name, :to => :person, :allow_nil => true, :prefix => true
    end
    rails = Project.new("Rails")
    assert_nil rails.person_name
  end

  def test_delegation_without_allow_nil_and_nil_value
    david = Someone.new("David")
    assert_raise(RuntimeError) { david.street }
  end

  def test_delegation_to_method_that_exists_on_nil
    nil_person = Someone.new(nil)
    assert_equal 0.0, nil_person.to_f
  end

  def test_delegation_to_method_that_exists_on_nil_when_allowing_nil
    nil_project = Project.new(nil)
    assert_equal 0.0, nil_project.to_f
  end

  def test_delegation_does_not_raise_error_when_removing_singleton_instance_methods
    parent = Class.new do
      def self.parent_method; end
    end

    assert_nothing_raised do
      Class.new(parent) do
        class << self
          delegate :parent_method, :to => :superclass
        end
      end
    end
  end
end
