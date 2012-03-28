module Gorillib
  module Model

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
    #     field :first_name, :default => "John"
    #     field :last_name,  :default => "Doe"
    #   end
    #
    #   person = Person.new
    #   person.first_name #=> "John"
    #   person.last_name  #=> "Doe"
    #
    # @example Dynamic Default
    #   class Event
    #     field :start_date
    #     field :end_date, :default => ->{ start_date }
    #   end
    #
    #   event = Event.receive(:start_date => Date.parse("2012-01-01"))
    #   event.end_date.to_s #=> "2012-01-01"
    #
    module FieldDefaults
      extend ActiveSupport::Concern

      # Applies the default values to fields
      #
      # Applies all the default values to any fields not yet set
      #
      # FIXME: avoid any field setter logic, such as dirty tracking.
      def apply_defaults!
        fields.each do |field|
          write_attribute(field.name, default_for(field)) unless attribute_set?(field.name)
        end
      end

    private

      # Calculates a field default
      #
      # @private
      def default_for(field)
        if field.default.respond_to?(:call)
          instance_exec(&default)
        else
          field.default.try_dup
        end
      end
    end

  end
end
