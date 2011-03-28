class Module
  def remove_possible_method(method)
    remove_method(method)
  rescue NameError
  end unless method_defined?(:remove_possible_method)

  def redefine_method(method, &block)
    remove_possible_method(method)
    define_method(method, &block)
  end unless method_defined?(:redefine_method)
end
