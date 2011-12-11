require File.expand_path('../spec_helper', File.dirname(__FILE__))
require GORILLIB_ROOT_DIR('spec/support/kcode_test_helper')
require 'gorillib/string/truncate'

describe String do
  describe '#truncate' do
    it 'leaves a short string alone' do
      "Hello World!".truncate(12).should == "Hello World!"
    end
    it 'truncates a long string' do
      "Hello World!!".truncate(12).should == "Hello Wor..."
    end

    it 'truncates with omission and separator' do
      "Hello World!".truncate(10, :omission => "[...]")                        .should  == "Hello[...]"
      "Hello Big World!".truncate(13, :omission => "[...]", :separator => ' ') .should  == "Hello[...]"
      "Hello Big World!".truncate(14, :omission => "[...]", :separator => ' ') .should  == "Hello Big[...]"
      "Hello Big World!".truncate(15, :omission => "[...]", :separator => ' ') .should  == "Hello Big[...]"
    end

    if RUBY_VERSION < '1.9.0'
      it 'works with unicode when kcode=none' do
        Gorillib::KcodeTestHelper.with_kcode('none') do
          "\354\225\210\353\205\225\355\225\230\354\204\270\354\232\224".truncate(10).
            should == "\354\225\210\353\205\225\355..."
        end
      end

      # # FIXME: breaks on ruby 1.8
      # it 'works with unicode when kcode=u' do
      #   Gorillib::KcodeTestHelper.with_kcode('u') do
      #     "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 \354\225\204\353\235\274\353\246\254\354\230\244".truncate(10).
      #       should == "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 ..."
      #   end
      # end
    else # ruby 1.9
      it 'works with unicode' do
        "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 \354\225\204\353\235\274\353\246\254\354\230\244".force_encoding('UTF-8').truncate(10).
          should == "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 ...".force_encoding('UTF-8')
      end
    end
  end
end
