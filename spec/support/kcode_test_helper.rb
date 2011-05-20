module Gorillib
  module KcodeTestHelper
    def self.with_kcode(code)
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
  end
end
