module Receiver
  def tree_diff(other)
    diff_hsh = {}
    other = other.symbolize_keys if other.respond_to?(:symbolize_keys)
    each do |k, v|
      case
      when v.is_a?(Array) && other[k].is_a?(Array)
        val = v.tree_diff(other[k])
        diff_hsh[k] = val unless val.blank?
      when v.respond_to?(:tree_diff) && other[k].respond_to?(:to_hash)
        val = v.tree_diff(other[k])
        diff_hsh[k] = val unless val.blank?
      else
        diff_hsh[k] = v unless v == other[k]
      end
    end
    other_hsh = other.dup.delete_if{|k, v| has_key?(k) }
    diff_hsh.merge!(other_hsh)
  end

  module ActsAsHash
    def <=>(other)
      return 1 if other.blank?
      each_key do |k|
        if has_key?(k) && other.has_key?(k)
          cmp = self[k] <=> other[k]
          return cmp unless cmp == 0
        end
      end
      0
    end
  end
end

class Array
  def tree_diff(other)
    arr = dup
    if other.length > arr.length then arr = arr + ([nil] * (other.length - arr.length)) end
    diff_ary = arr.zip(other).map do |arr_el, other_el|
      if arr_el.respond_to?(:tree_diff)  && other_el.respond_to?(:to_hash)
        arr_el.tree_diff(other_el)
      else
        (arr_el == other_el) ? nil : [arr_el, other_el]
      end
    end.reject(&:blank?)
  end
end

class Hash
  # Returns a hash that represents the difference between two hashes.
  #
  # Examples:
  #
  #   {1 => 2}.tree_diff(1 => 2)         # => {}
  #   {1 => 2}.tree_diff(1 => 3)         # => {1 => 2}
  #   {}.tree_diff(1 => 2)               # => {1 => 2}
  #   {1 => 2, 3 => 4}.tree_diff(1 => 2) # => {3 => 4}
  def tree_diff(other)
    diff_hsh = self.dup
    each do |k, v|
      case
      when v.is_a?(Array) && other[k].is_a?(Array)
        diff_hsh[k] = v.tree_diff(other[k])
        diff_hsh.delete(k) if diff_hsh[k].blank?
      when v.respond_to?(:tree_diff)  && other[k].respond_to?(:to_hash)
        diff_hsh[k] = v.tree_diff(other[k])
        diff_hsh.delete(k) if diff_hsh[k].blank?
      else diff_hsh.delete(k) if v == other[k]
      end
    end
    other_hsh = other.dup.delete_if{|k, v| has_key?(k) || has_key?(k.to_s) }
    diff_hsh.merge!(other_hsh)
  end
end
