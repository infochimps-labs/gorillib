require 'gorillib/metaprogramming/delegation'

class NamedList
  attr_reader :key_method
  DEFAULT_KEY_METHOD = :to_key

  attr_reader :clxn
  protected   :clxn

  delegate :[], :[]=, :delete, :fetch,                  :to => :clxn
  delegate :keys, :values, :each_pair, :each_value,     :to => :clxn
  delegate :has_key?, :length, :size, :empty?, :blank?, :to => :clxn

  def initialize(clxn={}, key_method=DEFAULT_KEY_METHOD)
    @key_method = key_method
    @clxn       = convert_collection(clxn)
  end

  def to_a    ; values    ; end
  def to_hash ; clxn.dup  ; end

  def merge!(other)
    clxn.merge!( convert_collection(other) )
  end
  alias_method :concat,   :merge!
  alias_method :receive!, :merge!

  def merge(other)
    dup.merge!(other)
  end

  def <<(val)
    merge! [val]
    self
  end

  def to_s           ; to_a.to_s           ; end
  def inspect        ; to_a.inspect        ; end
  def as_json(*args) ; to_a.as_json(*args) ; end
  def to_json(*args) ; to_a.to_json(*args) ; end

protected

  def convert_collection(cc)
    return cc.to_hash if cc.respond_to?(:to_hash)
    cc.inject({}) do |acc, val|
      key = val.public_send(key_method)
      acc[key] = val
      acc
    end
  end
end
