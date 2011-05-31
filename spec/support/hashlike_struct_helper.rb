StructUsingHashlike = Struct.new(:a, :b, :c, :nil_val, :false_val, :new_key) do
  include Gorillib::Hashlike
  include Gorillib::Struct::ActsAsHash

  def to_s ; to_hash.to_s ; end
  def inspect ; to_s ; end

  # compares so nil key is same as missing key
  def ==(othr)
    self.each_pair{|k,v| return false unless (v == othr[k]) }
    othr.each_pair{|k,v| return false unless (v == self[k]) }
    true
  end
end

module HashlikeFuzzingHelper
  SPECIAL_CASES_FOR_HASHLIKE_STRUCT = Hash.new({}).merge({
      :[]    => [
        [0], [1], [2], [100], [-1], # numeric keys are interpreted as positional args
        [:z], ['z'],                # Struct doesn't allow access to undefined keys
        [:z,  STRING_2X_PROC],
        ['z', STRING_2X_PROC],
        [:z, 100, STRING_2X_PROC],
      ],
      :[]=   => [
        [:z, :a], ['z', :a],        # Struct doesn't allow access to undefined keys
        [:z, 100, STRING_2X_PROC],
      ],
      :store     => [
        [:z, :a], ['z', :a],        # Struct doesn't allow access to undefined keys
        [:z, 100, STRING_2X_PROC],
      ],
      :each_pair => [
        [TOTAL_V_PROC],             # Struct behaves differently on arity 1
      ],
    })
end
