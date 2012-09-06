module Kernel
  def assert(value, message="Assertion failed", error=StandardError)
    raise error, message, caller unless value
  end
end

class NullObject
  def method_missing(*args, &block)
    self
  end

  def nil?; true; end
end

def Maybe(value)
  value.nil? ? NullObject.new : value
end
