require 'spec_helper'
require 'gorillib/exception/raisers'

describe 'raisers' do
  def should_raise_my_error(msg=nil)
    msg ||= error_message
    expect{ yield }.to raise_error(described_class, msg)
  end
  def should_return_true
    yield.should be_true
  end
  def capture_error
    message = 'should have raised, did not'
    begin
      yield
    rescue described_class => err
      message = err.message
    end
    return message.gsub(/of arguments\(/, 'of arguments (')
  end

  describe ArgumentError do

    context '.check_arity!' do
      let(:error_message){ /wrong number of arguments/ }
      it 'checks against a range' do
        should_raise_my_error{ described_class.check_arity!(['a'], 2..5) }
        should_raise_my_error{ described_class.check_arity!(['a'], 2..2) }
        should_return_true{    described_class.check_arity!(['a'], 0..5) }
        should_return_true{    described_class.check_arity!(['a'], 1..1) }
      end
      it 'checks against an array' do
        should_raise_my_error{ described_class.check_arity!( ['a', 'b'], [1, 3, 5] ) }
        should_return_true{    described_class.check_arity!( ['a', 'b'], [1, 2] ) }
      end
      it 'given a single number, requires exactly that many args' do
        should_raise_my_error{ described_class.check_arity!( ['a', 'b'], 1 ) }
        should_raise_my_error{ described_class.check_arity!( ['a', 'b'], 3 ) }
        should_return_true{    described_class.check_arity!( ['a', 'b'], 2 ) }
      end
      it 'matches the message a native arity error would' do
        should_raise_my_error(capture_error{ [].fill()   }){ described_class.check_arity!([],  1..3) }
        should_raise_my_error(capture_error{ [].to_s(1)  }){ described_class.check_arity!([1], 0) }
      end
    end

    context '.arity_at_least!' do
      let(:error_message){ /wrong number of arguments/ }
      it 'raises if there are fewer than that many args' do
        should_raise_my_error{ described_class.arity_at_least!(['a'], 2) }
        should_raise_my_error{ described_class.arity_at_least!([],    1) }
      end
      it ('returns true if there are that many args or more') do
        should_return_true{    described_class.arity_at_least!([],    0) }
        should_return_true{    described_class.arity_at_least!(['a'], 0) }
        should_return_true{    described_class.arity_at_least!(['a'], 1) }
      end
    end
  end
end
