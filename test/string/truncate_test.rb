# encoding: utf-8
require File.dirname(__FILE__)+'/../abstract_unit'
require File.dirname(__FILE__)+'/inflector_test_cases'
require 'gorillib/string/truncate'

class StringInflectionsTest < Test::Unit::TestCase
  include InflectorTestCases

  def test_truncate
    assert_equal "Hello World!", "Hello World!".truncate(12)
    assert_equal "Hello Wor...", "Hello World!!".truncate(12)
  end

  def test_truncate_with_omission_and_seperator
    assert_equal "Hello[...]", "Hello World!".truncate(10, :omission => "[...]")
    assert_equal "Hello[...]", "Hello Big World!".truncate(13, :omission => "[...]", :separator => ' ')
    assert_equal "Hello Big[...]", "Hello Big World!".truncate(14, :omission => "[...]", :separator => ' ')
    assert_equal "Hello Big[...]", "Hello Big World!".truncate(15, :omission => "[...]", :separator => ' ')
  end

  if RUBY_VERSION < '1.9.0'
    def test_truncate_multibyte
      with_kcode 'none' do
        assert_equal "\354\225\210\353\205\225\355...", "\354\225\210\353\205\225\355\225\230\354\204\270\354\232\224".truncate(10)
      end
      with_kcode 'u' do
        assert_equal "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 ...",
          "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 \354\225\204\353\235\274\353\246\254\354\230\244".truncate(10)
      end
    end
  else
    def test_truncate_multibyte
      assert_equal "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 ...".force_encoding('UTF-8'),
        "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 \354\225\204\353\235\274\353\246\254\354\230\244".force_encoding('UTF-8').truncate(10)
    end
  end
end
