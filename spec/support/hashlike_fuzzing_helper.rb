require 'stringio'

::Enumerator = Enumerable::Enumerator if (RUBY_VERSION < '1.9') && (not defined?(::Enumerator))

module HashlikeFuzzingHelper

  #
  # Fuzz testing for hashlike behavior. This throws a whole bunch of
  #
  #

  HASH_TO_TEST_FULLY_HASHLIKE = {
    :a  => 100,  :b  => 200, :c => 300,
    :nil_val => nil, :false_val => false, :true_val => true, :arr_val => [1,2,3],
    [1, 2, [3, 4]] => [1, [2, 3, [4, 5, 6]]],
    nil => :has_nil_key, false => :has_false_key, Object.new => :has_dummy_key,
  }.freeze

  #
  # Inputs to throw at it
  #

  STRING_2X_PROC   = Proc.new{|k|   k.to_s * 2 }
  TOTAL_K_PROC     = Proc.new{|k|   @total += self[k].to_i }
  TOTAL_V_PROC     = Proc.new{|v|   @total += v.to_i }
  TOTAL_KV_PROC    = Proc.new{|k,v| @total += v.to_i }
  VAL_GTE_4_PROC   = Proc.new{|k,v| v.respond_to?(:to_i) && v.to_i >= 4   }
  VAL_GTE_0_PROC   = Proc.new{|k,v| v.respond_to?(:to_i) && v && v.to_i >= 0   }
  VAL_GTE_1E6_PROC = Proc.new{|k,v| v.respond_to?(:to_i) && v && v.to_i >= 1e6 }

  INPUTS_FOR_ALL_HASHLIKES = [
    [], [:a], [:b], [:z], [0], [1], [2], [100], [-1],
    [:a, :b], [:a, 30], [:b, 50], [:z, :a], [:c, 70],
    [TOTAL_KV_PROC], [TOTAL_K_PROC], [TOTAL_V_PROC],
    [:a, STRING_2X_PROC], [:z, STRING_2X_PROC], [:z, 100, STRING_2X_PROC],
    [:a, :b, :z], [:a, :b, :a, :c, :a],
    [VAL_GTE_4_PROC], [VAL_GTE_0_PROC], [VAL_GTE_1E6_PROC],
  ]

  INPUTS_WHEN_INDIFFERENT_ACCESS = [
    ['a'], [:a], ['z'], [:z],
    [:a, :b], [:a, 'b'], ['a', 'b'], [:a, :z], [:z, :a], ['z', :a],
    ['a', STRING_2X_PROC], ['z', STRING_2X_PROC], ['a', 100, STRING_2X_PROC],
    [:b, 50], ['b', 50],
    [:a, 'b', :z],
  ]

  INPUTS_WHEN_ARBITRARY_KEYS_ALLOWED = [
    [], ['a'], ['b'], ['z'], [1], [0], [nil], [false], [''], [Object.new], [ [] ],
    ['a', 'b'], ['a', 30], ['b', 50], ['z', 'a'], [nil, 60], [:c, 70], [Object.new, 70], [ [], [] ],
    ['a', 'b', 'z'], ['a', 'b', 'a', :c, 'a'],
    [[1, 2, [3, 4]]], [[1, [2, 3, [4, 5, 6]]]]
  ]

  INPUTS_WHEN_FULLY_HASHLIKE = INPUTS_FOR_ALL_HASHLIKES + INPUTS_WHEN_ARBITRARY_KEYS_ALLOWED + INPUTS_WHEN_INDIFFERENT_ACCESS

  #
  # Hacky methods to do comparison
  #

  def send_to obj, meth, input
    if input.last.is_a?(Proc)
      input, block = [input[0..-2], input.last]
      obj.send(meth, *input, &block)
    else
      obj.send(meth, *input)
    end
  end

  # workaround: some errors have slightly different strings than Hash does
  def err_regex err
    err_str = err.to_s
    err_str = Regexp.escape(err_str)
    if err.is_a?(TypeError)
      err_str.gsub!(/nil/,   '(nil|NilClass)')
      err_str.gsub!(/false/, '(false|FalseClass)')
    elsif err.is_a?(ArgumentError)
      err_str.gsub!(/arguments(\\ )*\\\(/, 'arguments\s*\(')
      err_str.gsub!(/for\\ (\d\\\.\\\.\d)/, 'for [\d\.]+')
    end
    Regexp.new(err_str)
  end

  def behaves_the_same obj_1, obj_2, method_to_test, input
    input.unshift(1) if [:cycle, :partition].include?(method_to_test) && input.last.is_a?(Proc)

    # Hash in 1.8.7 behaves differently when arity mismatched to method
    if ((RUBY_VERSION < '1.9') &&
        [:reject!, :delete_if, :each_pair, :select, :reject].include?(method_to_test) &&
        input.last.is_a?(Proc) && (input.last.arity == 1))
      return
    end

    quiet_output do
      obj_1.should_receive(:warn){|str| stderr_output << str }.at_most(:once)
      begin
        expected = send_to(obj_1, method_to_test, input)
      rescue Exception => e
        expected = e
      end
      expected_stderr = $stderr.string

      obj_1.should_receive(:warn){|str| stderr_output << str }.at_most(:once)
      case expected
      when Exception
        lambda{ send_to(obj_2, method_to_test, input) }.should raise_error(expected.class, err_regex(expected))
      when Enumerator
        actual = send_to(obj_2, method_to_test, input)
        actual.should be_a(Enumerator)
        actual.inspect.gsub(/[\"\:]/, '').gsub(/0x[a-f\d]+/,'').should == expected.inspect.gsub(/[\"\:]/, '').gsub(/0x[a-f\d]+/,'')
      else # run the method
        actual = send_to(obj_2, method_to_test, input)
        if expected.is_a?(Hash) && (RUBY_VERSION < '1.9')
          actual.should be_hash_eql(expected)
        elsif expected.is_a?(Array) && (RUBY_VERSION < '1.9')
          actual.should be_array_eql(expected)
        else
          actual.should == expected
        end
      end
      $stderr.string.sub(/.*\.rb:\d+:(?:in `send\w*':)? /, '').should == expected_stderr.sub(/.*\.rb:\d+:(?:in `send\w*':)? /, '')
    end
  end

end
