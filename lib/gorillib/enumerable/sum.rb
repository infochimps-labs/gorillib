module Enumerable
  # Calculates a sum from the elements. Examples:
  #
  #  payments.sum { |p| p.price * p.tax_rate }
  #  payments.sum(&:price)
  #
  # The latter is a shortcut for:
  #
  #  payments.inject(0) { |sum, p| sum + p.price }
  #
  # It can also calculate the sum without the use of a block.
  #
  #  [5, 15, 10].sum # => 30
  #  ["foo", "bar"].sum # => "foobar"
  #  [[1, 2], [3, 1, 5]].sum => [1, 2, 3, 1, 5]
  #
  # The default sum of an empty list is zero. You can override this default:
  #
  #  [].sum(Payment.new(0)) { |i| i.amount } # => Payment.new(0)
  #
  def sum(identity = 0, &block)
    if block_given?
      map(&block).sum(identity)
    else
      inject { |sum, element| sum + element } || identity
    end
  end unless method_defined?(:sum)
end

class Range #:nodoc:
  # Optimize range sum to use arithmetic progression if a block is not given and
  # we have a range of numeric values.
  def sum(identity = 0)
    return super if block_given? || !(first.instance_of?(Integer) && last.instance_of?(Integer))
    actual_last = exclude_end? ? (last - 1) : last
    (actual_last - first + 1) * (actual_last + first) / 2
  end unless method_defined?(:sum)
end
