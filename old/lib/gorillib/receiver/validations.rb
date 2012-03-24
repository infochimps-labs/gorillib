module Receiver

  # An array of strings describing any ways this fails validation
  def validation_errors
    errors = []
    if (ma = missing_attrs).present?
      errors << "Missing values for {#{ma.join(",")}}"
    end
    errors
  end

  # returns a list of required but missing attributes
  def missing_attrs
    missing = []
    self.class.required_rcvrs.each do |name, info|
      missing << name if (not attr_set?(name))
    end
    missing
  end

  # methods become class-level
  module ClassMethods

    # class method gives info for all receiver attributes with required => true
    def required_rcvrs
      receiver_attrs.select{|name, info|  info[:required] }
    end
  end

end
