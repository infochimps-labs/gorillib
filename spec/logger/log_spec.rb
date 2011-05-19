require File.dirname(__FILE__)+'/../spec_helper'
CODE_FILE = File.dirname(__FILE__)+'/../../lib/gorillib/logger/log.rb'
require CODE_FILE

describe 'Logger' do
  describe '#dump' do
    it 'inspects each arg and sends tab-separated to Log.debug' do
      Log.should_receive(:debug).with(%Q{{:hi=>"there"}\t3\t"bye"})
      Log.dump({ :hi => "there" }, 3, "bye")
    end
  end

  it 'does not create a log if one exists' do
    dummy = 'dummy'
    Object.instance_eval{ remove_const(:Log) rescue nil ; ::Log = dummy }
    load(CODE_FILE)
    ::Log.should equal(dummy)
    Object.instance_eval{ remove_const(:Log) rescue nil }
  end

  it 'creates a new log to STDERR' do
    @old_stderr = $stderr
    $stderr = StringIO.new
    Object.instance_eval{ remove_const(:Log) rescue nil }
    load(CODE_FILE)
    Log.info 'hi mom'
    $stderr.string.should =~ /hi mom/
    $stderr = @old_stderr
  end

end
