require 'gorillib/string/inflector'
class String

  # +constantize+ tries to find a declared constant with the name specified
  # in the string. It raises a NameError when the name is not in CamelCase
  # or is not initialized.  See Gorillib::Inflector.constantize
  #
  # Examples
  #   "Module".constantize  # => Module
  #   "Class".constantize   # => Class
  #   "blargle".constantize # => NameError: wrong constant name blargle
  def constantize
    Gorillib::Inflector.constantize(self)
  end unless method_defined?(:constantize)

  # +safe_constantize+ tries to find a declared constant with the name specified
  # in the string. It returns nil when the name is not in CamelCase
  # or is not initialized.  See Gorillib::Model::Inflector.safe_constantize
  #
  # Examples
  #   "Module".safe_constantize  # => Module
  #   "Class".safe_constantize   # => Class
  #   "blargle".safe_constantize # => nil
  def safe_constantize
    Gorillib::Inflector.safe_constantize(self)
  end unless method_defined?(:safe_constantize)

end
