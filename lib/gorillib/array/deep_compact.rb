require 'gorillib/object/blank'

#
# deep_compact! removes all 'blank?' elements in the array in place, recursively
#
class Array
  def deep_compact!
    self.map! do |val|
      case val
      when Hash
        val = val.deep_compact!
      when Array
        val = val.deep_compact!
      when String
        val = nil if val.blank?
      end
      val
    end
    self.compact!
    self.blank? ? nil : self
  end
end
