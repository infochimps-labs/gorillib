require 'active_model'

module Receiver
  class ActiveModelShim
    extend ActiveModel::Naming

    def to_model
      self
    end

    def valid?()      true  end
    def new_record?() true  end
    def destroyed?()  false end

    def errors
      @_errors ||= ActiveModel::Errors.new(self)
    end
  end
end
