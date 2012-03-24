# require 'active_model'

require 'active_model/deprecated_error_methods'
require 'active_model/errors'
require 'active_model/naming'
require 'active_model/validator'
require 'active_model/translation'
require 'active_model/validations'
require 'active_support/i18n'
I18n.load_path << File.join(File.expand_path(File.dirname(__FILE__)), 'locale/en.yml')

module Receiver
  module ActiveModelShim

    def to_model
      self
    end

    def new_record?() true  end
    def destroyed?()  false end
    def errors
      @_errors ||= ActiveModel::Errors.new(self)
    end

    def self.included(base)
      base.class_eval do
        extend  ActiveModel::Naming
        include ActiveModel::Validations
      end
    end
  end
end
