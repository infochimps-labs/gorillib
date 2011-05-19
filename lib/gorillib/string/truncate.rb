class String
  # Truncates a given +text+ after a given <tt>length</tt> if +text+ is longer than <tt>length</tt>:
  #
  #   "Once upon a time in a world far far away".truncate(27)
  #   # => "Once upon a time in a wo..."
  #
  # The last characters will be replaced with the <tt>:omission</tt> string (defaults to "...")
  # for a total length not exceeding <tt>:length</tt>:
  #
  #   "Once upon a time in a world far far away".truncate(27, :separator => ' ')
  #   # => "Once upon a time in a..."
  #
  # Pass a <tt>:separator</tt> to truncate +text+ at a natural break:
  #
  #   "And they found that many people were sleeping better.".truncate(25, :omission => "... (continued)")
  #   # => "And they f... (continued)"
  def truncate(length, options = {})
    text = self.dup
    chars        = text.respond_to?(:mb_chars)      ? text.mb_chars            : text
    omission     = options[:omission] || "..."
    omission_len = omission.respond_to?(:mb_chars)  ? omission.mb_chars.length : omission.length
    length_with_room_for_omission = length - omission_len

    if (separator = options[:separator])
      separator_chars = separator.respond_to?(:mb_chars) ? separator.to_s.mb_chars  : separator.to_s
      stop = chars.rindex(separator_chars, length_with_room_for_omission) || length_with_room_for_omission
    else
      stop = length_with_room_for_omission
    end

    (chars.length > length ? chars[0...stop] + omission : text).to_s
  end unless method_defined?(:truncate)
end
