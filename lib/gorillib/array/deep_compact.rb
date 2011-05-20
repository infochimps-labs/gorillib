require 'gorillib/object/blank'

#
# deep_compact! removes all 'blank?' elements in the array in place, recursively
#
class Array
  def deep_compact!
    self.map! do |val|
      val.deep_compact! if val.respond_to?(:deep_compact!)
      val unless val.blank?
    end.compact!
  end
end
