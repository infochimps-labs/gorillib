
class String
  def camelize(*args) Gorillib::String::Inflections.camelize(self, *args) ; end
  def snakeize(*args) Gorillib::String::Inflections.snakeize(self, *args) ; end
  def underscore(*args) Gorillib::String::Inflections.underscore(self, *args) ; end
  def demodulize(*args) Gorillib::String::Inflections.demodulize(self, *args) ; end
end
