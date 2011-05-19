require 'gorillib/string/inflections'
require 'gorillib/array/extract_options'

class String

  # Capitalizes the first word and turns underscores into spaces and strips a
  # trailing "_id", if any. Like +titleize+, this is meant for creating pretty output.
  #
  # @example
  #   "employee_salary" #=> "Employee salary"
  #   "author_id" #=> "Author"
  def humanize
    self.gsub(/_id$/, '').tr('_', ' ').capitalize
  end unless method_defined?(:humanize)

  # Capitalizes all the words and replaces some characters in the string to create
  # a nicer looking title. +titleize+ is meant for creating pretty output. It is not
  # used in the Rails internals.
  #
  # Examples:
  #   "man from the boondocks".titleize # => "Man From The Boondocks"
  #   "x-men: the last stand".titleize  # => "X Men: The Last Stand"
  def titleize
    self.underscore.humanize.gsub(/\b('?[a-z])/){ $1.capitalize }
  end unless method_defined?(:titleize)
end

class Array
  # Converts the array to a comma-separated sentence where the last element is joined by the connector word. Options:
  # * <tt>:words_connector</tt> - The sign or word used to join the elements in arrays with two or more elements (default: ", ")
  # * <tt>:two_words_connector</tt> - The sign or word used to join the elements in arrays with two elements (default: " and ")
  # * <tt>:last_word_connector</tt> - The sign or word used to join the last element in arrays with three or more elements (default: ", and ")
  def to_sentence(options = {})
    default_words_connector     = ", "
    default_two_words_connector = " and "
    default_last_word_connector = ", and "
    options = { :words_connector => default_words_connector, :two_words_connector => default_two_words_connector, :last_word_connector => default_last_word_connector }.merge(options)

    case length
      when 0
        ""
      when 1
        self[0].to_s.dup
      when 2
        "#{self[0]}#{options[:two_words_connector]}#{self[1]}"
      else
        "#{self[0...-1].join(options[:words_connector])}#{options[:last_word_connector]}#{self[-1]}"
    end
  end unless method_defined?(:to_sentence)
end
