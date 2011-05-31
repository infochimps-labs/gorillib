RSpec::Matchers.define(:enumerate_method) do |obj, meth|
  match do |enum|
    if RUBY_VERSION < '1.9'
      enum.is_a?(Enumerable::Enumerator)
    else
      enum.is_a?(Enumerator) &&
        (enum.inspect == "#<Enumerator: #{obj.inspect}:#{meth}>")
    end
  end
end
