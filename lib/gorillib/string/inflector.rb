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
module Gorillib::Inflector
  extend self

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
  def camelize(str, first_letter = :upper)
    camelized = str.gsub(/\/(.?)/){ "::#{ $1.upcase }" }.gsub(/(?:^|_)(.)/){ $1.upcase }
    (first_letter == :lower) ? (str[0..0].downcase + camelized[1..-1]) : camelized
  end

  # Converts strings to snakeCase, also known as lowerCamelCase.
  #
  # +snakeize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  # @example:
  #   "active_record".snakeize                # => "activeRecord"
  #   "active_record/errors".snakeize         # => "activeRecord::Errors"
  #
  def snakeize(str)
    camelize(str, :lower)
  end

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
  def underscore(str)
    word = str.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  # Replaces underscores with dashes in the string.
  #
  # Example:
  #   "puni_puni" # => "puni-puni"
  def dasherize(underscored_word)
    underscored_word.gsub(/_/, '-')
  end

  # Removes the module part from the expression in the string:
  #
  # @example
  #   "Gorillib::Inflections".demodulize #=> "Inflections"
  #   "Inflections".demodulize                   #=> "Inflections"
  #
  # See also +deconstantize+.
  def demodulize(str)
    str.gsub(/^.*::/, '')
  end

  # Removes the rightmost segment from the constant expression in the string:
  #
  #   "Net::HTTP".deconstantize   # => "Net"
  #   "::Net::HTTP".deconstantize # => "::Net"
  #   "String".deconstantize      # => ""
  #   "::String".deconstantize    # => ""
  #   "".deconstantize            # => ""
  #
  # See also +demodulize+.
  def deconstantize(path)
    path.to_s[0...(path.rindex('::') || 0)] # implementation based on the one in facets' Module#spacename
  end

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
  def constantize(str)
    unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ str
      raise NameError, "#{self.inspect} is not a valid constant name!"
    end

    Object.module_eval("::#{$1}", __FILE__, __LINE__)
  end

  # Tries to find a constant with the name specified in the argument string:
  #
  #   "Module".safe_constantize     # => Module
  #   "Test::Unit".safe_constantize # => Test::Unit
  #
  # The name is assumed to be the one of a top-level constant, no matter whether
  # it starts with "::" or not. No lexical context is taken into account:
  #
  #   C = 'outside'
  #   module M
  #     C = 'inside'
  #     C                    # => 'inside'
  #     "C".safe_constantize # => 'outside', same as ::C
  #   end
  #
  # nil is returned when the name is not in CamelCase or the constant (or part of it) is
  # unknown.
  #
  #   "blargle".safe_constantize  # => nil
  #   "UnknownModule".safe_constantize  # => nil
  #   "UnknownModule::Foo::Bar".safe_constantize  # => nil
  #
  def safe_constantize(camel_cased_word)
    begin
      constantize(camel_cased_word)
    rescue NameError => e
      raise unless e.message =~ /uninitialized constant #{const_regexp(camel_cased_word)}$/ ||
        e.name.to_s == camel_cased_word.to_s
    rescue ArgumentError => e
      raise unless e.message =~ /not missing constant #{const_regexp(camel_cased_word)}\!$/
    end
  end

  # Turns a number into an ordinal string used to denote the position in an
  # ordered sequence such as 1st, 2nd, 3rd, 4th.
  #
  # Examples:
  #   ordinalize(1)     # => "1st"
  #   ordinalize(2)     # => "2nd"
  #   ordinalize(1002)  # => "1002nd"
  #   ordinalize(1003)  # => "1003rd"
  #   ordinalize(-11)   # => "-11th"
  #   ordinalize(-1021) # => "-1021st"
  def ordinalize(number)
    if (11..13).include?(number.to_i.abs % 100)
      "#{number}th"
    else
      case number.to_i.abs % 10
      when 1; "#{number}st"
      when 2; "#{number}nd"
      when 3; "#{number}rd"
      else    "#{number}th"
      end
    end
  end

private

  # Mount a regular expression that will match part by part of the constant.
  # For instance, Foo::Bar::Baz will generate Foo(::Bar(::Baz)?)?
  def const_regexp(camel_cased_word) #:nodoc:
    parts = camel_cased_word.split("::")
    last  = parts.pop

    parts.reverse.inject(last) do |acc, part|
      part.empty? ? acc : "#{part}(::#{acc})?"
    end
  end

end
