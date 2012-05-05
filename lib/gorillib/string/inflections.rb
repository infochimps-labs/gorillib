
class String
  def camelize(*args)   Gorillib::String::Inflector.camelize(self, *args) ; end
  def snakeize(*args)   Gorillib::String::Inflector.snakeize(self, *args) ; end
  def underscore(*args) Gorillib::String::Inflector.underscore(self, *args) ; end
  def demodulize(*args) Gorillib::String::Inflector.demodulize(self, *args) ; end
end
