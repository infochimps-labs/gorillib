ORIG_ARGV = ARGV.dup

curr = File.expand_path(File.dirname(__FILE__))
$:.unshift(curr) unless $:.include?('curr') || $:.include?(curr)
lib  = File.expand_path("#{File.dirname(__FILE__)}/../lib")
$:.unshift(lib) unless $:.include?('lib') || $:.include?(lib)

require 'test/unit'

def with_kcode(code)
  if RUBY_VERSION < '1.9'
    begin
      old_kcode, $KCODE = $KCODE, code
      yield
    ensure
      $KCODE = old_kcode
    end
  else
    yield
  end
end

if RUBY_VERSION < '1.9'
  $KCODE = 'UTF8'
end
