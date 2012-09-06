require 'gorillib/string/inflector'
class String

  # Find a declared constant with the name specified in the string, or raise.
  #
  # @example
  #   "Module".constantize  # => Module
  #   "Class".constantize   # => Class
  #   "blargle".constantize # => NameError: wrong constant name blargle
  #
  # @raise [NameError] when the name is not in CamelCase or is not initialized.
  # @return [Module,Class] the specified class
  # @see Gorillib::Inflector.constantize
  def constantize
    Gorillib::Inflector.constantize(self)
  end

  # Find a declared constant with the name specified in the string, or return nil.
  #
  # @return [Module,Class] the specified class, or nil when the name is not in
  # CamelCase or is not initialized.
  #
  # @example
  #   "Module".safe_constantize  # => Module
  #   "Class".safe_constantize   # => Class
  #   "blargle".safe_constantize # => nil
  #
  # @see Gorillib::Model::Inflector.safe_constantize
  # @return [Module,Class] the specified constant,
  #   or nil when the name is not in CamelCase or is not initialized.
  def safe_constantize
    Gorillib::Inflector.safe_constantize(self)
  end

end
