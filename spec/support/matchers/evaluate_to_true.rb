RSpec::Matchers.define(:evaluate_to_true) do |meth, *args|
  match{|obj| obj.send(meth, *args) == true }
  failure_message_for_should{|obj|     "expected #{obj.inspect} to #{meth} #{args.join(",")}"}
  failure_message_for_should_not{|obj| "expected #{obj.inspect} to not #{meth} #{args.join(",")}"}
end
