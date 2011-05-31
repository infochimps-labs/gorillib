RSpec::Matchers.define(:be_array_eql) do |other_arr|
  diffable
  if RUBY_VERSION < '1.9'
    match do |obj|
      obj.sort_by(&:inspect) == other_arr.sort_by(&:inspect)
    end
  else
    match do |obj|
      obj == other_arr
    end
  end
end
