require 'gorillib/test_helpers/capture_output'
RSpec.configure{|c| c.include Gorillib::TestHelpers }

describe '', :hashlike_spec => true do

  # ===========================================================================
  #
  # Fundamental behavior

  shared_examples_for :hashlike_store_and_retrieve do
    it 'stores and retrieves values' do
      @hshlike[:a].should == 100
      @hshlike[:a] = 999
      @hshlike[:a].should == 999
    end

    it 'returns nil on a missing (but valid) key' do
      @hshlike[:new_key].should == nil
    end
  end

  shared_examples_for :references_string_and_symbol_keys_equivalently do
    it 'treats string and symbol keys as the same thing' do
      @hshlike['c'].should == 300
      @hshlike[:c].should  == 300
      @hshlike['c'] = 999
      @hshlike['c'].should == 999
      @hshlike[:c].should  == 999
      @hshlike.delete('c').should == 999
      @hshlike['c'].should be_nil
      @hshlike[:c].should  be_nil
    end
  end

  shared_examples_for :references_complex_keys do
    it 'treats string and symbol keys as distinct' do
      @hshlike['c'].should be_nil
      @hshlike[:c].should  == 300
      @hshlike['c'] = 999
      @hshlike['c'].should == 999
      @hshlike[:c].should  == 300
      @hshlike.delete('c').should == 999
      @hshlike['c'].should be_nil
      @hshlike[:c].should  == 300
    end

    it 'allows nil, Object, and other non-stringy keys' do
      @hshlike[300] = :i_haz_num ; @hshlike[300].should == :i_haz_num; @hshlike.delete(300).should == :i_haz_num
      @hshlike[nil] = :i_haz_nil ; @hshlike[nil].should == :i_haz_nil; @hshlike.delete(nil).should == :i_haz_nil
      obj = Object.new
      @hshlike[obj] = :i_haz_obj ; @hshlike[obj].should == :i_haz_obj; @hshlike.delete(obj).should == :i_haz_obj
      @hshlike.should be_hash_eql(HashlikeHelper::BASE_HSH)
    end
  end

  shared_examples_for :accepts_arbitrary_keys do
    it 'never-seen keys' do
      @hshlike[:fnord] = 69
      @hshlike[:fnord].should == 69
      @hshlike.delete(:fnord).should == 69
      @hshlike[:boink].should be_nil
    end
  end

  shared_examples_for :hashlike_delete do
    it 'removes the key/value association and returns the value' do
      @hshlike.delete(:a).should == 100
      @hshlike.delete(:is_missing).should be_nil
      @hshlike.delete(:false_val).should == false
      @hshlike.should be_hash_eql({ :b  => 200, :c => 300, :nil_val => nil })
    end
    describe 'with optional code block' do
      it 'returns the value of executing the block (passing in the key)' do
        set_in_block = nil
        ret_val = @hshlike.delete(:is_missing){|k| set_in_block = "got: #{k}" ; "hello!" }
        set_in_block.should == "got: is_missing"
        ret_val.should == "hello!"
      end
    end
    it 'does not include? key after deleting' do
      @hshlike.should include(:a)
      @hshlike.delete(:a)
      @hshlike.should_not include(:a)
      @hshlike[:a].should be_nil
    end
  end

  shared_examples_for :hashlike_keys do
    it 'lists keys, even where values are nil' do
      @hshlike.keys.should be_array_eql([:a, :b, :c, :nil_val, :false_val])
      @hshlike[:nil_val].should be_nil
    end
    it 'is an empty array when there are no keys' do
      @empty_hshlike.keys.should == []
    end
    it 'setting an association creates a new key' do
      @hshlike[:new_key] = 3
      @hshlike.keys.should be_array_eql([:a, :b, :c, :nil_val, :false_val, :new_key])
    end
  end

  # ===========================================================================
  #
  # Iteration

  shared_examples_for :with_no_block_returns_enumerator do |method_to_test|
    it('returns an enumerator'){ @hshlike.send(method_to_test).should enumerate_method(@hshlike, method_to_test) }
  end

  shared_examples_for :each_pair_on_stringlike_keys do |method_to_test|
    it 'calls block once for each key/value pair in hsh' do
      seen_arg1 = []
      seen_arg2 = []
      @hshlike.send(method_to_test){|arg1,arg2| seen_arg1 << arg1 ; seen_arg2 << arg2 }
      seen_arg1.should be_array_eql([:a,  :b,  :c, :nil_val, :false_val ])
      seen_arg2.should be_array_eql([100, 200, 300, nil,      false      ])
    end
    it 'with arity 1, returns arrays' do
      seen_args = []
      @hshlike.send(method_to_test){|arg| seen_args << arg }
      seen_args.should be_array_eql([[:a, 100], [:b, 200], [:c, 300], [:nil_val, nil], [:false_val, false]])
    end
    it 'handles array vals' do
      seen_args = []
      @hshlike_with_array_vals.send(method_to_test){|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, [100, 111], nil], [:b, 200, nil], [:c, [1, [2, 3, [4, 5, 6]]], nil]])
      seen_args = []
      @hshlike_with_array_vals.send(method_to_test){|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, [100, 111]], [:b, nil, 200], [:c, nil, [1, [2, 3, [4, 5, 6]]]]])
    end
    it 'returns self' do
      ret_val = @hshlike.send(method_to_test){|k,v| 3 }
      ret_val.should equal(@hshlike)
    end
  end

  #
  # For a struct, the keys exist eternally, so even an unset key/value pair is iterated
  #
  shared_examples_for :each_pair_on_stringlike_fixed_keys do |method_to_test|
    it 'calls block once for each key/value pair in hsh' do
      seen_arg1 = []
      seen_arg2 = []
      @hshlike.send(method_to_test){|arg1,arg2| seen_arg1 << arg1 ; seen_arg2 << arg2 }
      seen_arg1.should be_array_eql([:a,  :b,  :c, :nil_val, :false_val, :new_key ])
      seen_arg2.should be_array_eql([100, 200, 300, nil,      false,      nil      ])
    end
    it 'with arity 1, returns array pairs' do
      seen_args = []
      @hshlike.send(method_to_test){|arg| seen_args << arg }
      # seen_args.should be_array_eql([[:a, 100], [:b, 200], [:c, 300], [:nil_val, nil], [:false_val, false], [:new_key, nil]])
      seen_args.should be_array_eql([:a, :b, :c, :nil_val, :false_val, :new_key])
    end
    it 'handles array vals' do
      seen_args = []
      @hshlike_with_array_vals.send(method_to_test){|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, [100, 111], nil], [:b, 200, nil], [:c, [1, [2, 3, [4, 5, 6]]], nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
      seen_args = []
      @hshlike_with_array_vals.send(method_to_test){|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, [100, 111]], [:b, nil, 200], [:c, nil, [1, [2, 3, [4, 5, 6]]]], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
    end
    it 'returns self' do
      ret_val = @hshlike.send(method_to_test){|k,v| 3 }
      ret_val.should equal(@hshlike)
    end
  end

  shared_examples_for :each_key_on_stringlike_keys do
    it 'calls block once for each key in hsh' do
      seen_keys = []
      @hshlike.each_key{|k| seen_keys << k }
      seen_keys.should be_array_eql([:a,  :b,  :c, :nil_val, :false_val ])
    end
    it 'handles array vals and extra arity' do
      seen_args = []
      @hshlike.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil] ])
      seen_args = []
      @hshlike_with_array_vals.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil] ])
      seen_args = []
      @hshlike_with_array_vals.each_key{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil] ])
    end
    it 'returns self' do
      ret_val = @hshlike.each_key{|k,v| 3 }
      ret_val.should equal(@hshlike)
    end
  end

  #
  # For a struct, the keys exist eternally, so even an unset key/value pair is iterated
  #
  shared_examples_for :each_key_on_stringlike_fixed_keys do |method_to_test|
    it 'calls block once for each key in hsh' do
      seen_keys = []
      @hshlike.each_key{|k| seen_keys << k }
      seen_keys.should be_array_eql([:a,  :b,  :c, :nil_val, :false_val, :new_key ])
    end
    it 'handles array keys and extra arity' do
      seen_args = []
      @hshlike.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil] ])
      seen_args = []
      @hshlike_with_array_vals.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
      seen_args = []
      @hshlike_with_array_vals.each_key{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
    end
    it 'returns self' do
      ret_val = @hshlike.each_key{|k,v| 3 }
      ret_val.should equal(@hshlike)
    end
  end

  shared_examples_for :each_value_on_stringlike_keys do
    it 'calls block once for each key in hsh, passing the value as parameter' do
      seen_vals = []
      @hshlike.each_value{|k| seen_vals << k }
      seen_vals.should be_array_eql([100, 200, 300, nil, false])
    end
    it 'calls block on each value even when nil, false, empty or duplicate' do
      @hshlike[:a]       = 999
      @hshlike[:new_key] = 999
      seen_vals = []
      @hshlike.each_value{|k| seen_vals << k }
      seen_vals.should be_array_eql([999, 200, 300, nil, false, 999])
    end
    it 'handles array vals and extra arity' do
      seen_args = []
      @hshlike.each_value{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[100, nil, nil], [200, nil, nil], [300, nil, nil], [nil, nil, nil], [false, nil, nil]])
      seen_args = []
      @hshlike_with_array_vals.each_value{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[100, 111, nil], [200, nil, nil], [1, [2, 3, [4, 5, 6]], nil]])
      seen_args = []
      @hshlike_with_array_vals.each_value{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[100, nil, 111], [200, nil, nil], [1, nil, [2, 3, [4, 5, 6]]]])
    end
    it 'returns self' do
      ret_val = @hshlike.each_value{|k,v| 3 }
      ret_val.should equal(@hshlike)
    end
  end

  #
  # For a struct, the keys exist eternally, so even an unset key/value pair is iterated
  #
  shared_examples_for :each_value_on_stringlike_fixed_keys do
    it 'calls block once for each key in hsh, passing the value as parameter' do
      seen_vals = []
      @hshlike.each_value{|k| seen_vals << k }
      seen_vals.should be_array_eql([100, 200, 300, nil, false, nil])
    end
    it 'calls block on each value even when nil, false, empty or duplicate' do
      @hshlike[:a]       = 999
      @hshlike[:new_key] = 999
      seen_vals = []
      @hshlike.each_value{|k| seen_vals << k }
      seen_vals.should be_array_eql([999, 200, 300, nil, false, 999 ])
    end
    it 'handles array vals and extra arity' do
      seen_args = []
      @hshlike.each_value{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[100, nil, nil], [200, nil, nil], [300, nil, nil], [nil, nil, nil], [false, nil, nil], [nil, nil, nil]])
      seen_args = []
      @hshlike_with_array_vals.each_value{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[100, 111, nil], [200, nil, nil], [1, [2, 3, [4, 5, 6]], nil], [nil, nil, nil], [nil, nil, nil], [nil, nil, nil]])
      seen_args = []
      @hshlike_with_array_vals.each_value{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[100, nil, 111], [200, nil, nil], [1, nil, [2, 3, [4, 5, 6]]], [nil, nil, nil], [nil, nil, nil], [nil, nil, nil]])
    end
    it 'returns self' do
      ret_val = @hshlike.each_value{|k,v| 3 }
      ret_val.should equal(@hshlike)
    end
  end

  shared_examples_for :each_pair_on_complex_keys do |method_to_test|
    it 'handles array keys' do
      seen_args = []
      @hshlike_with_array_keys.each_pair{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[[:a, :aa], 100, nil], [:b, 200, nil], [[:c, :cc], [300, 333], nil], [[1, 2, [3, 4]], [1, [2, 3, [4, 5, 6]]], nil]])
      seen_args = []
      @hshlike_with_array_keys.each_pair{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, :aa, 100], [:b, nil, 200], [:c, :cc, [300, 333]], [1, 2, [1, [2, 3, [4, 5, 6]]]]])
    end
  end

  shared_examples_for :each_key_on_complex_keys do
    it 'handles array keys and extra arity' do
      seen_args = []
      @hshlike.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil]])
      seen_args = []
      @hshlike_with_array_keys.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, :aa, nil], [:b, nil, nil], [:c, :cc, nil], [1, 2, [3, 4]]])
      seen_args = []
      @hshlike_with_array_keys.each_key{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      seen_args.should be_array_eql([[:a, nil, :aa], [:b, nil, nil], [:c, nil, :cc], [1, nil, 2]])
    end
  end

  # ===========================================================================
  #
  # Retrieval and Membership

  shared_examples_for :hashlike_values do
    it 'returns a new array populated with the values from hsh' do
      @hshlike.values.should be_array_eql([100, 200, 300, nil, false])
    end
  end

  shared_examples_for :hashlike_values_at_or_of do |method_to_test|
    it 'returns an array containing the values associated with the given keys' do
      @hshlike.send(method_to_test, :b, :a, :z, :nil_val).should == [200, 100, nil, nil]
    end
    it 'returns duplicate keys or missing keys in given slot' do
      @hshlike.send(method_to_test, :b, :b, :i_am_missing, :nil_val, :c, '300').should == [200, 200, nil, nil, 300, nil]
    end
  end

  shared_examples_for :hashlike_length do |method_to_test|
    it 'returns the number of key/value pairs in the hashlike' do
      @hshlike.send(method_to_test).should == 5
      @hshlike[:new_key] = 69
      @hshlike.send(method_to_test).should == 6
      @hshlike.delete(:a)
      @hshlike.delete(:b)
      @hshlike.send(method_to_test).should == 4
    end
    it 'is zero for an empty hashlike' do
      @empty_hshlike.send(method_to_test).should == 0
    end
  end

  shared_examples_for :hashlike_has_key? do |method_to_test|
    it 'returns true if the given key is present' do
      @hshlike.send(method_to_test, :a).should == true
    end
    it 'returns false if the key is absent, whether pre-defined or not' do
      @hshlike.send(method_to_test, :new_key).should == false
      @hshlike[:new_key] = nil
      @hshlike.send(method_to_test, :new_key).should == true
      @hshlike.send(method_to_test, :fnord).should == false
    end
    it 'is true even if value is nil, empty or false' do
      @hshlike.should evaluate_to_true(method_to_test, :nil_val)
      @hshlike.should evaluate_to_true(method_to_test, :false_val)
    end
    it 'something something convert_key' unless ENV['QUIET_RSPEC']
  end

  shared_examples_for :hashlike_has_key_predefined_always_present do |method_to_test|
    it 'returns true if the given key is present' do
      @hshlike.send(method_to_test, :a).should == true
    end
    it 'returns false if the key is absent, whether pre-defined or not' do
      @hshlike.send(method_to_test, :new_key).should == true
      @hshlike[:new_key] = nil
      @hshlike.send(method_to_test, :new_key).should == true
      @hshlike.send(method_to_test, :fnord).should == false
    end
    it 'is true even if value is nil, empty or false' do
      @hshlike.should evaluate_to_true(method_to_test, :nil_val)
      @hshlike.should evaluate_to_true(method_to_test, :false_val)
    end
    it 'something something convert_key' unless ENV['QUIET_RSPEC']
  end

  shared_examples_for :hashlike_has_key_string_and_symbol_equivalent do |method_to_test|
    it 'treats symbol and string keys as equivalent' do
      @hshlike.send(method_to_test, :a).should  == true
      @hshlike.send(method_to_test, 'a').should == true
      @hshlike.send(method_to_test, :c).should  == true
      @hshlike.send(method_to_test, 'c').should == true
    end
  end

  shared_examples_for :hashlike_has_key_on_complex_keys do |method_to_test|
    it 'treats symbol and string keys as equivalent' do
      @hshlike.send(method_to_test, :a).should  == true
      @hshlike.send(method_to_test, 'a').should == false
      @hshlike.send(method_to_test, :c).should  == true
      @hshlike.send(method_to_test, 'c').should == false
      @hshlike.send(method_to_test, nil).should == false
      @hshlike[nil] = 1
      @hshlike.send(method_to_test, nil).should == true
      obj = Object.new
      @hshlike.send(method_to_test, obj).should == false
      @hshlike[obj] = 1
      @hshlike.send(method_to_test, obj).should == true
    end
  end

  shared_examples_for :hashlike_has_value? do |method_to_test|
    it 'returns true if the given value is present' do
      @hshlike.send(method_to_test, 100).should == true
    end
    it 'returns false if the value is absent' do
      @hshlike.send(method_to_test, :i_am_missing).should == false
    end
    it 'returns true if the given value is present-but-nil or present-but-false' do
      @hshlike[:false_val].should == false
      @hshlike[:nil_val].should   == nil
      @hshlike.send(method_to_test, false).should == true
      @hshlike.send(method_to_test, nil).should   == true
    end
    it 'something something convert_key' unless ENV['QUIET_RSPEC']
  end

  shared_examples_for :hashlike_has_value_on_complex_keys do |method_to_test|
    it 'is true even if key or value is nil, empty or false values' do
      @hshlike[nil]   = :key_is_nil
      @hshlike[false] = :key_is_false
      @hshlike.should be_hash_eql({:a=>100, :b=>200, :c=>300, :nil_val=>nil, :false_val=>false, nil=>:key_is_nil, false=>:key_is_false})
      @hshlike.should evaluate_to_true(method_to_test, nil)
      @hshlike.should evaluate_to_true(method_to_test, false)
      @hshlike.should evaluate_to_true(method_to_test, :key_is_nil)
      @hshlike.should evaluate_to_true(method_to_test, :key_is_false)
    end
  end

  shared_examples_for :hashlike_fetch do
    it 'returns a value from the hashlike for the given key' do
      @hshlike.fetch(:a).should       == 100
      @hshlike.fetch(:c).should       == 300
      @hshlike.fetch(:nil_val).should == nil
    end
    describe 'on a missing key' do
      it 'with no other arguments, raises a +KeyError+ exception' do
        lambda{ @hshlike.fetch(:new_key) }.should raise_error(KeyError, 'key not found: :new_key')
      end
      it 'if block given, runs the block with the given key and returns its value' do
        set_in_block = nil
        ret_val = @hshlike.fetch(:new_key){|k| set_in_block = "got: #{k}" ; "hello!" }
        ret_val.should      == "hello!"
        set_in_block.should == "got: new_key"
      end
      it 'if default given, returns the default arg' do
        ret_val = @hshlike.fetch(:new_key, :returned_as_default)
        ret_val.should      == :returned_as_default
      end
      it 'if block and default are both given, issues a warning and runs the block' do
        quiet_output do
          set_in_block = nil
          ret_val = @hshlike.fetch(:new_key, :spurious_default){|k| set_in_block = "got: #{k}" ; "hello!" }
          ret_val.should      == "hello!"
          set_in_block.should == "got: new_key"
        end
      end
    end
    it 'something something convert_key' unless ENV['QUIET_RSPEC']
  end

  shared_examples_for :hashlike_key do
    it 'searches for an entry with the given val, returning the corresponding key; if not found, returns nil' do
      @hshlike.key(100).should == :a
      @hshlike.key(300).should == :c
      @hshlike.key(nil).should == :nil_val
      @hshlike.key(:i_am_missing).should be_nil
    end
    it 'returns the first matching key/value pair' do
      @hshlike[:a]       = 999
      @hshlike[:new_key] = 999
      if (RUBY_VERSION >= '1.9')
        @hshlike.key(999).should == :a
      end
    end
  end

  shared_examples_for :hashlike_assoc do
    it 'searches for an entry with the given key, returning the corresponding key/value pair' do
      @hshlike.assoc(:a).should       == [:a,  100]
      @hshlike.assoc(:nil_val).should == [:nil_val, nil]
    end
    it 'returns nil if missing' do
      @hshlike.assoc(:i_am_missing).should be_nil
    end
    it 'something something convert_key' unless ENV['QUIET_RSPEC']
  end

  shared_examples_for :hashlike_rassoc do
    it 'searches for an entry with the given val, returning the corresponding key/value pair' do
      @hshlike.rassoc(100).should == [:a,  100]
      @hshlike.rassoc(300).should == [:c,  300]
      @hshlike.rassoc(nil).should == [:nil_val, nil]
    end
    it 'returns nil if missing' do
      @hshlike.rassoc(:i_am_missing).should be_nil
    end
  end

  shared_examples_for :hashlike_empty? do
    it 'returns true if the hashlike contains no key-value pairs, false otherwise' do
      @hshlike.empty?.should       == false
      @empty_hshlike.empty?.should == true
      @empty_hshlike[:a] = nil
      @empty_hshlike.empty?.should == false
    end
  end

  # ===========================================================================
  #
  # Update, merge!, merge

  shared_examples_for :merging_method do |method_to_test|
    it 'adds the contents of another hash' do
      ret_val = @hshlike.send(method_to_test, {:a => [], :new_key => "zzz" })
      ret_val.should   be_hash_eql({:a=>[], :b=>200, :c=>300, :nil_val=>nil, :false_val=>false, :new_key => "zzz"})
    end
    it 'adds the contents of a Struct' do
      bob_klass = Struct.new(:a, :b, :nil_val, :new_key)
      bob = bob_klass.new("aaa", 200, "here", "zzz")
      ret_val = @hshlike.send(method_to_test, bob)
      ret_val.should   be_hash_eql({ :a => "aaa", :b => 200, :c => 300, :nil_val => "here", :false_val => false, :new_key => "zzz" })
      bob.values.should == ["aaa", 200, "here", "zzz"]
    end
    it 'adds the contents of another Hashlike' do
      bob = InternalHash.new.merge({ :a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val = @hshlike.send(method_to_test, bob)
      ret_val.should   be_hash_eql({ :a => "aaa", :b => 200, :c => 300, :nil_val => "here", :false_val => false, :new_key => "zzz" })
      bob.should       be_hash_eql({ :a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
    end
    it 'adds the contents of anything that respond_to?(:each_pair)' do
      obj = Object.new
      def obj.each_pair
        [[:a, "aaa"], [:b, 200], [:nil_val, "here"], [:new_key, "zzz"]].each{|k,v| yield(k,v) }
      end
      ret_val = @hshlike.send(method_to_test, obj)
      ret_val.should   be_hash_eql({ :a => "aaa", :b => 200, :c => 300, :nil_val => "here", :false_val => false, :new_key => "zzz" })
    end
    describe 'with no block' do
      it 'overwrites entries in this hash with those from the other hash' do
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
        ret_val.should be_hash_eql({ :a => "aaa", :b => 200, :c => 300, :nil_val => "here", :false_val => false, :new_key => "zzz" })
      end
    end
    it 'raises a type error unless given hash responds to each_pair' do
      obj = Object.new
      lambda{ @hshlike.send(method_to_test, obj) }.should raise_error(TypeError, "can't convert Object into Hash")
    end
    it 'something something convert_key' unless ENV['QUIET_RSPEC']
  end

  shared_examples_for :merging_method_with_normal_keys do |method_to_test|
    describe 'with a block' do
      it 'sets the value for colliding keys by evaluating the block' do
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :nil_val => "here", :new_key => "zzz" }) do |key, other_val, hsh_val|
          "key: '#{key.inspect}', other_val: '#{other_val.inspect}', hsh_val: '#{hsh_val.inspect}'"
        end
        ret_val.should be_hash_eql({
            :a         => %Q{key: ':a', other_val: '"aaa"', hsh_val: '100'},
            :b         => 200,
            :c        => 300,
            :nil_val   => %Q{key: ':nil_val', other_val: '"here"', hsh_val: 'nil'},
            :false_val => false,
            :new_key   => "zzz",
          })
      end
      it 'passes params |key, current val, other hash val|' do
        seen_args = []
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :nil_val => "here", :new_key => "zzz" }) do |key, other_val, hsh_val|
          seen_args << [key, other_val, hsh_val]
          3
        end
        ret_val.should be_hash_eql({ :a => 3, :b => 200, :c => 300, :nil_val => 3, :false_val => false, :new_key => "zzz" })
        seen_args.should be_array_eql([ [:a, "aaa", 100], [:nil_val, "here", nil] ])
      end
      it 'calls the block even if colliding keys have same value' do
        seen_args = []
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :b => 200, :new_key => "zzz" }) do |key, other_val, hsh_val|
          seen_args << [key, other_val, hsh_val]
          3
        end
        ret_val.should be_hash_eql({ :a => 3, :b => 3, :c => 300, :nil_val => nil, :false_val => false, :new_key => "zzz" })
        seen_args.should be_array_eql([ [:a, "aaa", 100], [:b, 200, 200] ])
      end
    end
  end

  shared_examples_for :merging_method_with_struct_keys do |method_to_test|
    describe 'with a block' do
      it 'sets the value for colliding keys by evaluating the block' do
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :nil_val => "here", :new_key => "zzz" }) do |key, other_val, hsh_val|
          "key: '#{key.inspect}', other_val: '#{other_val.inspect}', hsh_val: '#{hsh_val.inspect}'"
        end
        ret_val.should be_hash_eql({
            :a         => %Q{key: ':a', other_val: '"aaa"', hsh_val: '100'},
            :b         => 200,
            :c         => 300,
            :nil_val   => %Q{key: ':nil_val', other_val: '"here"', hsh_val: 'nil'},
            :false_val => false,
            :new_key   => %Q{key: ':new_key', other_val: '"zzz"', hsh_val: 'nil'},
          })
      end
      it 'passes params |key, current val, other hash val|' do
        seen_args = []
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :nil_val => "here", :new_key => "zzz" }) do |key, other_val, hsh_val|
          seen_args << [key, other_val, hsh_val]
          3
        end
        ret_val.should be_hash_eql({ :a => 3, :b => 200, :c => 300, :nil_val => 3, :false_val => false, :new_key => 3 })
        seen_args.should be_array_eql([ [:a, "aaa", 100], [:nil_val, "here", nil], [:new_key, "zzz", nil] ])
      end
      it 'calls the block even if colliding keys have same value' do
        seen_args = []
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :b => 200, :new_key => "zzz" }) do |key, other_val, hsh_val|
          seen_args << [key, other_val, hsh_val]
          3
        end
        ret_val.should be_hash_eql({ :a => 3, :b => 3, :c => 300, :nil_val => nil, :false_val => false, :new_key => 3 })
        seen_args.should be_array_eql([ [:a, "aaa", 100], [:b, 200, 200], [:new_key, "zzz", nil] ])
      end
    end
  end

  shared_examples_for :merging_method_inplace do |method_to_test|
    it 'updates in-place, returning self' do
      ret_val = @hshlike.send(method_to_test, {:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val.should equal(@hshlike)
      @hshlike.should be_hash_eql({:a=>"aaa", :b=>200, :c=>300, :nil_val=>"here", :false_val=>false, :new_key=>"zzz"})
    end
  end

  shared_examples_for :merging_method_returning_new do |method_to_test|
    it 'does not alter state, returning a new object' do
      ret_val = @hshlike.send(method_to_test, {:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val.should_not equal(@hshlike)
      @hshlike.should be_hash_eql({:a=>100,   :b=>200, :c=>300, :nil_val=>nil,    :false_val=>false })
      ret_val.should  be_hash_eql({:a=>"aaa", :b=>200, :c=>300, :nil_val=>"here", :false_val=>false, :new_key=>"zzz"})
    end
    it 'returns an object of same class' do
      ret_val = @hshlike_subklass_inst.send(method_to_test, {:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val.should be_a(@hshlike_subklass)
    end
  end

  # ===========================================================================
  #
  # Filters

  shared_examples_for :hashlike_filter do |method_to_test|
    it 'passes every key-value pair to block' do
      seen_args = []
      ret_val = @hshlike.send(method_to_test){|key,val| seen_args << [key, val] ; val && (val.to_i > 150) }
      #
      seen_args.should be_array_eql([[:a, 100], [:b, 200], [:c, 300], [:nil_val, nil], [:false_val, false]])
    end
    it 'adapts to the arity of the block' do
      seen_args = []
      ret_val = @hshlike.send(method_to_test){|arg| seen_args << [arg] ; @hshlike[arg] && (@hshlike[arg].to_i > 150) }
      #
      seen_args.should be_array_eql([[:a], [:b], [:c], [:nil_val], [:false_val]])
    end
    describe 'with no block' do
      it('returns an enumerator'){ @hshlike.send(method_to_test).should enumerate_method(@hshlike, method_to_test) }
    end
  end

  shared_examples_for :rejection_filter do |method_to_test|
    it 'deletes every key-value pair for which the block evaluates truthy' do
      ret_val = @hshlike.send(method_to_test){|key,val| val && (val.to_i > 150) }
      ret_val.should be_hash_eql({ :a => 100, :nil_val => nil, :false_val => false })
      @hshlike.should be_hash_eql({ :a => 100, :nil_val => nil, :false_val => false })
      #
      ret_val = @hshlike.send(method_to_test){|key,val| 1 }
      ret_val.should be_empty
    end
  end

  shared_examples_for :selection_filter do |method_to_test|
    it 'deletes every key-value pair for which the block evaluates truthy' do
      ret_val = @hshlike.keep_if{|key,val| val }
      ret_val.should be_hash_eql({ :a => 100, :b => 200, :c => 300  })
      #
      ret_val = @hshlike.keep_if{|key,val| val && (val.to_i > 150) }
      ret_val.should be_hash_eql({ :b => 200, :c => 300  })
      #
      ret_val = @hshlike.keep_if{|key,val| false }
      ret_val.should be_empty
    end
  end

  shared_examples_for :filter_modifies_self_returns_nil_if_unchanged do |method_to_test, force_unchanged|
    it 'modifies in-place and returns self if changes were made' do
      ret_val = @hshlike.send(method_to_test){|key,val| val && (val.to_i > 150) }
      ret_val.should equal(@hshlike)
    end
    it 'modifies in-place and returns self if changes were made (arity 1)' do
      ret_val = @hshlike.send(method_to_test){|key| @hshlike[key] && (@hshlike[key].to_i > 150) }
      ret_val.should equal(@hshlike)
    end
    it 'returns nil if unchanged' do
      ret_val = @hshlike.send(method_to_test){|key,val| force_unchanged }
      #
      ret_val.should be_nil
      @hshlike.should be_hash_eql(HashlikeHelper::BASE_HSH)
    end
  end

  shared_examples_for :filter_modifies_self_returns_self do |method_to_test, force_unchanged|
    it 'modifies in-place and returns self if changes were made' do
      ret_val = @hshlike.send(method_to_test){|key,val| val && (val.to_i > 150) }
      ret_val.should equal(@hshlike)
    end
    it 'modifies in-place and returns self if changes were made (arity 1)' do
      ret_val = @hshlike.send(method_to_test){|key| @hshlike[key] && (@hshlike[key].to_i > 150) }
      ret_val.should equal(@hshlike)
    end
    it 'returns self if unchanged' do
      ret_val = @hshlike.send(method_to_test){|key,val| force_unchanged }
      #
      ret_val.should     equal(@hshlike)
      @hshlike.should    be_hash_eql(HashlikeHelper::BASE_HSH)
    end
  end

  shared_examples_for :filter_does_not_modify_self_returns_same_class do |method_to_test, force_unchanged|
    it 'modifies in-place and returns self' do
      ret_val = @hshlike.send(method_to_test){|key,val| val && (val.to_i > 150) }
      ret_val.should_not be_hash_eql(@hshlike)
      ret_val.should_not equal(@hshlike)
      @hshlike.should    be_hash_eql(HashlikeHelper::BASE_HSH)
    end
    it 'is == if unchanged' do
      ret_val = @hshlike.send(method_to_test){|key,val| force_unchanged }
      #
      ret_val.should_not equal(@hshlike)
      ret_val.should     be_hash_eql(@hshlike)
      @hshlike.should    be_hash_eql(HashlikeHelper::BASE_HSH)
    end
    it 'returns same class as caller' do
      ret_val = @hshlike_subklass_inst.send(method_to_test){|key,val| val && (val.to_i > 150) }
      ret_val.should be_a(@hshlike_subklass)
      ret_val.should be_a(@hshlike.class)
      ret_val.class.should_not == @hshlike.class
    end
  end

  shared_examples_for :hashlike_clear do
    it 'removes all key/value pairs' do
      ret_val = @hshlike.clear
      ret_val.should be_hash_eql(@empty_hshlike)
      ret_val.should be_empty
      @hshlike.should be_empty
    end
  end

  # ===========================================================================
  #
  # Conversion

  shared_examples_for :hashlike_to_hash do
    it 'returns a new Hash with each key set to its associated value' do
      ret_val = @hshlike.to_hash
      ret_val.should be_an_instance_of(Hash)
      ret_val.should == HashlikeHelper::BASE_HSH
    end
  end

  shared_examples_for :hashlike_invert do
    if (RUBY_VERSION >= '1.9')
      it 'returns a new Hash using the values as keys, and the keys as values' do
        ret_val = @hshlike.invert
        ret_val.should == { 100 => :a, 200 => :b, 300 => :c, nil => :nil_val, false => :false_val }
      end
      it 'with duplicate values, the result will contain only one of them as a key' do
        @hshlike[:a]       = 999
        @hshlike[:new_key] = 999
        @hshlike.invert.should == { 999 => :new_key, 200 => :b, 300 => :c, nil => :nil_val, false => :false_val }
      end
      it 'returns a Hash, not a self.class' do
        ret_val = @hshlike.invert
        ret_val.should be_an_instance_of(Hash)
      end
    else
      it 'does not have tests for invert on Ruby < 1.9'
    end
  end

  shared_examples_for :hashlike_flatten do
    if (RUBY_VERSION >= '1.9')
      it 'with no arg returns a one-dimensional flattening' do
        ret_as_hash = HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.flatten
        ret_val     = @hshlike_with_array_vals.flatten
        ret_val.should == ret_as_hash
        ret_val.should == [  :a, [100, 111],  :b, 200,    :c, [1, [2, 3, [4, 5, 6]]],  ]
        @hshlike_with_array_vals.should be_hash_eql(HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS)
      end
      it 'with no arg is same as level = 1' do
        @hshlike_with_array_vals.flatten(1).should == @hshlike_with_array_vals.flatten
      end
      it 'with level == nil, returns a complete flattening' do
        ret_as_hash = HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.flatten(nil)
        ret_val     = @hshlike_with_array_vals.flatten(nil)
        ret_val.should == ret_as_hash
        ret_val.should == [  :a,  100, 111,    :b,  200,  :c, 1,  2, 3,  4, 5, 6,       ]
      end
      it 'with an arg, flattens to that level (0)' do
        ret_as_hash = HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.flatten(0)
        ret_val     = @hshlike_with_array_vals.flatten(0)
        ret_val.should == ret_as_hash
        ret_val.should == [ [:a, [100, 111]], [:b, 200], [:c, [1, [2, 3, [4, 5, 6]]]], ]
      end
      it 'with an arg, flattens to that level (3)' do
        ret_as_hash = HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.flatten(3)
        ret_val     = @hshlike_with_array_vals.flatten(3)
        ret_val.should == ret_as_hash
        ret_val.should == [  :a,  100, 111,    :b, 200,   :c, 1,  2, 3, [4, 5, 6],]
      end
      it 'with an arg, flattens to that level (4)' do
        ret_as_hash = HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.flatten(4)
        ret_val     = @hshlike_with_array_vals.flatten(4)
        ret_val.should == ret_as_hash
        ret_val.should == [  :a,  100, 111,    :b, 200,   :c, 1,  2, 3,  4, 5, 6, ]
        ret_val.should == @hshlike_with_array_vals.flatten(999)
      end
    else
      it 'does not have tests for invert on Ruby < 1.9'
    end
  end

  ::HASHLIKE_BEHAVIOR_SPEC = true
end unless defined?(::HASHLIKE_BEHAVIOR_SPEC)
