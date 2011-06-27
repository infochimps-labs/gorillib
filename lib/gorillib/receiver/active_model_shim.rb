require 'active_model'

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
