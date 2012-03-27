module Gorillib
  module Model
    class Field
      remove_possible_method(:type)

      attr_accessor :name
      attr_accessor :type
      attr_accessor :doc
      attr_accessor :model

      
    end
  end
end
