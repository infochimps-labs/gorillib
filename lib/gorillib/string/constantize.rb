class String

  # Constantize tries to find a declared constant with the name specified
  # in the string. It raises a NameError when the name is not in CamelCase
  # or is not initialized.
  #
  # @example
  #   "Module".constantize #=> Module
  #   "Class".constantize #=> Class
  #
  # This is the extlib version of String#constantize, which has different
  # behavior wrt using lexical context: see active_support/inflector/methods.rb
  #
  def constantize
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ self
      raise NameError, "#{self.inspect} is not a valid constant name!"
    end

    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end unless method_defined?(:constantize)
end
