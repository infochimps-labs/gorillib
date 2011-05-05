require 'gorillib/object/blank'

#
# deep_compact! removes all keys with 'blank?' values in the hash, in place, recursively
#
class Hash
  def deep_compact!
    self.each do |key, val|
      case val
      when Hash
        val = val.deep_compact!
        self.delete(key) if val.blank?
      when Array
        val = val.deep_compact!
        self.delete(key) if val.blank?
      when String
        self.delete(key) if val.blank?
      when nil
        self.delete(key)
      end
    end
    self.blank? ? nil : self
  end
end
