require 'set'
require 'gorillib/object/blank'

class Array
  #
  # deep_compact! removes all 'blank?' elements in the array in place, recursively
  #
  def deep_compact!
    self.map! do |val|
      val.deep_compact! if val.respond_to?(:deep_compact!)
      val unless val.blank?
    end.compact!
  end
end
