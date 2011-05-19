require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/enumerable/sum'

Payment = Struct.new(:price)
class SummablePayment < Payment
  def +(p) self.class.new(price + p.price) end
end

describe Enumerable do
  describe '#sum' do
    it 'sums lists of numbers to a number' do
      [5, 15, 10].sum        .should == 30
      [5, 15, 10].sum{|i| i }.should == 30
    end

    it 'sums list of strings to a string' do

      %w(a b c).sum        .should == 'abc'
      %w(a b c).sum{|i| i }.should == 'abc'
    end

    it 'sums list of objects with a &:method' do
      payments = [ Payment.new(5), Payment.new(15), Payment.new(10) ]
      payments.sum(&:price)           .should == 30
      payments.sum { |p| p.price * 2 }.should == 60
    end

    it 'sums object with a synthetic "+" method' do
      payments = [ SummablePayment.new(5), SummablePayment.new(15) ]
      payments.sum        .should == SummablePayment.new(20)
      payments.sum{|p| p }.should == SummablePayment.new(20)
    end

    it 'handles nil sums' do
      lambda{ [5, 15, nil].sum }.should raise_error(TypeError)

      payments = [ Payment.new(5), Payment.new(15), Payment.new(10), Payment.new(nil) ]
      lambda{ payments.sum(&:price) }.should raise_error(TypeError)
      payments.sum{|p| p.price.to_i * 2 }.should == 60
    end

    it 'handles empty sums' do
      [].sum        .should == 0
      [].sum{|i| i }.should == 0
      [].sum(Payment.new(0)).should == Payment.new(0)
    end

    it 'behaves the same on ranges' do
      (1..4).sum{|i| i * 2 }.should == 20
      (1..4).sum            .should == 10
      (1..4.5).sum          .should == 10
      (1...4).sum           .should ==  6
      ('a'..'c').sum        .should == 'abc'
    end
  end
end
