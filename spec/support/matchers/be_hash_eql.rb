RSpec::Matchers.define(:be_hash_eql) do |othr|
  diffable
  match do |obj|
    if obj.respond_to?(:hash_eql?)
      obj.hash_eql?(othr)
    else
      # same = (obj.length == othr.length)
      same = true
      ( othr.each_pair{|k,v| same &&= (v == obj[k]) } &&
        obj .each_pair{|k,v| same &&= (v == othr[k]) })
      same
    end
  end
end
