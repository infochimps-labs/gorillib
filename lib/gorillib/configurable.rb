require 'configliere'
require 'gorillib/builder'
require 'gorillib/string/inflections'

module Gorillib    
  module Configurable
    extend Gorillib::Concern
    include Gorillib::Builder

    module ClassMethods
      def receive(attrs = {}, &blk)            
        conf = settings.load_configuration_in_order!(configuration_scope.to_s)
        super(attrs.merge(conf), &blk)
      end

      def config(name, type, options = {})
        field(name, type, options)
      end
    end
    
    included do
      self.class_attribute(:configuration_scope, :settings)
      self.configuration_scope = self.to_s.underscore.to_sym
      self.settings            = Configliere::Param.new.use(:commandline, :config_file)
    end
    
  end
end
