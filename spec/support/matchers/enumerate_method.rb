RSpec::Matchers.define(:enumerate_method) do |obj, meth|
  match do |enum|
    enum.is_a?(Enumerator) &&
      (enum.inspect == "#<Enumerator: #{obj.inspect}:#{meth}>")
  end
end
