require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'gorillib/test_helpers/capture_output'

describe Gorillib::TestHelpers, :simple_spec => true do

  context '.capture_output' do
    let(:mock_stdout){ StringIO.new('', 'w') }
    let(:mock_stderr){ StringIO.new('', 'w') }

    before do
      mock_stderr ; mock_stdout
      StringIO.should_receive(:new).and_return(mock_stdout)
      StringIO.should_receive(:new).and_return(mock_stderr)
    end

    it 'gives me a new $stdout and $stderr' do
      Gorillib::TestHelpers.capture_output do
        $stdout.should equal(mock_stdout)
        $stderr.should equal(mock_stderr)
      end
    end

    it 'yields a wrapped block' do
      i_wuz_here = nil
      Gorillib::TestHelpers.capture_output do
        i_wuz_here = true
      end
      i_wuz_here.should == true
    end

    it 'restores the original values' do
      old_stdout = $stdout ; old_stderr = $stderr
      Gorillib::TestHelpers.capture_output do
        $stdout.should equal(mock_stdout)
        $stderr.should equal(mock_stderr)
      end
      $stdout.should equal(old_stdout)
      $stderr.should equal(old_stderr)
    end

    it 'restores the original values even if there is an error' do
      old_stdout = $stdout ; old_stderr = $stderr
      Gorillib::TestHelpers.capture_output do
        raise 'hell'
      end rescue nil
      $stdout.should equal(old_stdout)
      $stderr.should equal(old_stderr)
    end

    it 'returns the captured streams' do
      returned_stdout, returned_stderr = Gorillib::TestHelpers.capture_output do
        $stdout.puts 'I was here'
        $stderr.puts 'so was I'
      end
      returned_stdout.should equal(mock_stdout)
      returned_stderr.should equal(mock_stderr)
      mock_stdout.string.should == "I was here\n"
      mock_stderr.string.should == "so was I\n"
    end

    it 'raises an error if no block is given' do
      lambda{ Gorillib::TestHelpers.capture_output }.should raise_error(LocalJumpError, "no block given (yield)")
    end

  end

  context '.quiet_output' do

  end

  it 'makes module_functions' do
    klass = Class.new
    klass.private_method_defined?(:capture_output).should be_false
    klass.private_method_defined?(:quiet_output  ).should be_false
    klass.send(:include, Gorillib::TestHelpers)
    klass.private_method_defined?(:capture_output).should be_true
    klass.private_method_defined?(:quiet_output  ).should be_true
  end

end
