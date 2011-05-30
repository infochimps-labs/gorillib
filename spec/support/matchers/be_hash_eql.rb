RSpec::Matchers.define(:be_hash_eql) do |other_hsh|
  diffable
  match do |obj|
    if obj.respond_to?(:hash_eql?)
      obj.hash_eql?(other_hsh)
    else
      return false unless (obj.length == other_hsh.length)
      other_hsh.each_pair{|k,v| return false unless (v == obj[k]) }
      true
    end
  end
end
