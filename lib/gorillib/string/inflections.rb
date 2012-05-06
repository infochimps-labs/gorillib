require 'gorillib/string/inflector'

class String
  def camelize(*args)   Gorillib::Inflector.camelize(self, *args) ; end
  def snakeize(*args)   Gorillib::Inflector.snakeize(self, *args) ; end
  def underscore(*args) Gorillib::Inflector.underscore(self, *args) ; end
  def demodulize(*args) Gorillib::Inflector.demodulize(self, *args) ; end
end
