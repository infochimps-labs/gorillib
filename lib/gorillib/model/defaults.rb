module Gorillib
  module Model

    Field.class_eval do
      field :default, :whatever

      # @return [true, false] true if the field has a default value/proc set
      def has_default?
        attribute_set?(:default)
      end
    end

    # This is called by `read_attribute` if an attribute is unset; you should
    # not call this directly.  You might use this to provide defaults, or lazy
    # access, or layered resolution.
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to unset.
    # @return [nil] Ze goggles! Zey do nussing!
    def read_unset_attribute(field_name)
      field = self.class.fields[field_name]
      return unless field.has_default?
      write_attribute(field.name, attribute_default(field))
    end

    # FieldDefaults allows defaults to be declared for your fields
    #
    # Defaults are declared by passing the :default option to the field
    # class method. If you need the default to be dynamic, pass a lambda, Proc,
    # or any object that responds to #call as the value to the :default option
    # and the result will calculated on initialization. These dynamic defaults
    # can depend on the values of other fields.
    #
    # @example Usage
    #   class Person
    #     field :first_name, String, :default => "John"
    #     field :last_name,  String, :default => "Doe"
    #   end
    #
    #   person = Person.new
    #   person.first_name #=> "John"
    #   person.last_name  #=> "Doe"
    #
    # @example Dynamic Default
    #   class Event
    #     field :start_date, Date
    #     field :end_date,   Date, :default => ->{ start_date }
    #   end
    #
    #   event = Event.receive(:start_date => "2012-01-01")
    #   event.end_date.to_s #=> "2012-01-01"
    #

  protected

    # the actual default value to assign to the attribute
    def attribute_default(field)
      return unless field.has_default?
      val = field.default
      case
      when (val.is_a?(Proc) || val.is_a?(UnboundMethod)) && (val.arity == 0)
        self.instance_exec(&val)
      when val.respond_to?(:call)
        val.call(self, field.name)
      else
        val.try_dup
      end
    end

  end

end
