require 'spec_helper'
require 'gorillib/string/truncate'

describe String, :string_spec => true do

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

    it 'works with unicode' do
      "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 \354\225\204\353\235\274\353\246\254\354\230\244".force_encoding('UTF-8').truncate(10).
        should == "\354\225\204\353\246\254\353\236\221 \354\225\204\353\246\254 ...".force_encoding('UTF-8')
    end
  end

end
