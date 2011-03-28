# String inflections define new methods on the String class to transform names for different purposes.
#
#   "ScaleScore".underscore # => "scale_score"
#
# This doesn't define the full set of inflections -- only
#
# * camelize
# * snakeize
# * underscore
# * demodulize
#
class String

  # By default, +camelize+ converts strings to UpperCamelCase. If the argument to +camelize+
  # is set to <tt>:lower</tt> then +camelize+ produces lowerCamelCase.
  #
  # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  # @example:
  #   "active_record".camelize                # => "ActiveRecord"
  #   "active_record".camelize(:lower)        # => "activeRecord"
  #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
  #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
  #
  # As a rule of thumb you can think of +camelize+ as the inverse of +underscore+,
  # though there are cases where that does not hold:
  #
  #   "SSLError".underscore.camelize # => "SslError"
  #
  def camelize(first_letter = :upper)
    camelized = self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    (first_letter == :lower) ? (self[0..0].downcase + camelized[1..-1]) : camelized
  end unless method_defined?(:camelize)

  # Converts strings to snakeCase, also known as lowerCamelCase.
  #
  # +snakeize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  # @example:
  #   "active_record".snakeize                # => "activeRecord"
  #   "active_record/errors".snakeize         # => "activeRecord::Errors"
  #
  def snakeize
    camelize :lower
  end unless method_defined?(:snakeize)

  # Makes an underscored, lowercase form from the expression in the string.
  #
  # +underscore+ will also change '::' to '/' to convert namespaces to paths.
  #
  # Examples:
  #   "ActiveRecord".underscore         # => "active_record"
  #   "ActiveRecord::Errors".underscore # => active_record/errors
  #
  # As a rule of thumb you can think of +underscore+ as the inverse of +camelize+,
  # though there are cases where that does not hold:
  #
  #   "SSLError".underscore.camelize # => "SslError"
  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end unless method_defined?(:underscore)

  # Removes the module part from the expression in the string
  #
  # @example
  #   "ActiveRecord::CoreExtensions::String::Inflections".demodulize #=> "Inflections"
  #   "Inflections".demodulize #=> "Inflections"
  def demodulize
    self.gsub(/^.*::/, '')
  end unless method_defined?(:demodulize)

end
