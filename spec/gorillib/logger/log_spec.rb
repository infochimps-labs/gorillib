require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'gorillib/logger/log'


describe 'Logger', :simple_spec => true do
  # so we can practice loading and unloading
  def logger_code_file
    GORILLIB_ROOT_DIR('lib/gorillib/logger/log.rb')
  end

  describe '#dump' do
    it 'inspects each arg and sends tab-separated to Log.debug' do
      Log.should_receive(:debug).with(%r{\{:hi=>"there"\}\t3\t\"bye\".*#{__FILE__}:.*in })
      Log.dump({ :hi => "there" }, 3, "bye")
    end
  end

  it 'does not create a log if one exists' do
    dummy = 'dummy'
    Object.instance_eval{ remove_const(:Log) rescue nil ; ::Log = dummy }
    load(logger_code_file)
    ::Log.should equal(dummy)
    Object.instance_eval{ remove_const(:Log) rescue nil }
  end

  it 'creates a new log to STDERR' do
    @old_stderr = $stderr
    $stderr = StringIO.new
    Object.instance_eval{ remove_const(:Log) rescue nil }
    load(logger_code_file)
    Log.info 'hi mom'
    $stderr.string.should =~ /hi mom/
    $stderr = @old_stderr
  end

end
