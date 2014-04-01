require 'log4r'

module Gorillib
  module Logger
    def self.included(base)
      base.send :include, ClassMethods
      base.extend ClassMethods
    end

    module ClassMethods
      def log
        logger_name = case self
                      when Module then name
                      else self.class.name
                      end
        @log ||= Log4r::Logger[logger_name] || Log4r::Logger.new(logger_name)
      end
    end
  end
end
