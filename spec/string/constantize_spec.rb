require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/string/constantize'

module Ace
  module Base
    class Case
      def lookup_from_instance(klass_name)
        klass_name.constantize
      end

      def self.lookup_from_class(klass_name)
        klass_name.constantize
      end
    end
  end
end

module InflectorTest

  describe 'String' do
    describe '#constantize' do
      it "works from within instance" do
        @obj = Ace::Base::Case.new
        @obj.lookup_from_instance('Ace::Base::Case').should  == Ace::Base::Case
        @obj.lookup_from_instance('Ace::Base').should        == Ace::Base
        @obj.lookup_from_instance('Ace').should              == Ace
      end

      it "works from within class" do
        @klass = Ace::Base::Case
        @klass.lookup_from_class('Ace::Base::Case').should  == Ace::Base::Case
        @klass.lookup_from_class('Ace::Base').should        == Ace::Base
        @klass.lookup_from_class('Ace').should              == Ace
      end

      it "does lookup from top down" do
        @obj = Ace::Base::Case.new
        lambda{ @obj.lookup_from_instance('Case') }.should raise_error(NameError)
        lambda{ @obj.lookup_from_instance('Base') }.should raise_error(NameError)
      end

      it "InflectorTest"     do InflectorTest.should   == "InflectorTest".constantize              ; end
      it "::InflectorTest"   do InflectorTest.should   == "::InflectorTest".constantize            ; end
      it "Ace::Base::Case"   do Ace::Base::Case.should == "Ace::Base::Case".constantize            ; end
      it "::Ace::Base::Case" do Ace::Base::Case.should == "::Ace::Base::Case".constantize          ; end
      it "UnknownClass"      do lambda{ "UnknownClass"     .constantize }.should raise_error(NameError) ; end
      it "An invalid string" do lambda{ "An invalid string".constantize }.should raise_error(NameError) ; end
      it "InvalidClass\n"    do lambda{ "InvalidClass\n"   .constantize }.should raise_error(NameError) ; end

      it 'does lexical lookup' do
        lambda{ "Ace::Base::InflectorTest".constantize }.should raise_error(NameError)
      end
    end
  end

end
