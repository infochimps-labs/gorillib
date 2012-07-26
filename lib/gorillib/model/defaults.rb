module Gorillib
  module Model

    Field.class_eval do
      field :default, :whatever

      # @return [true, false] true if the field has a default value/proc set
      def has_default?
        attribute_set?(:default)
      end
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

    # This is called by `read_attribute` if an attribute is unset; you should
    # not call this directly.  You might use this to provide defaults, or lazy
    # access, or layered resolution.
    # 
    # Once a non-nil default value has been read, it is **fixed on the field**; this method
    # will not be called again, and `attribute_set?(...)` will return `true`.
    #
    # @example values are fixed on read
    #     class Defaultable
    #       include Gorillib::Model
    #       field :timestamp, Integer, default: ->{ Time.now }
    #     end
    #     dd = Defaultable.new
    #     dd.attribute_set?(:timestamp) # => false
    #     dd.timestamp                  # => '2012-01-02 12:34:56 CST'
    #     dd.attribute_set?(:timestamp) # => true
    #     # The block is *not* re-run -- the time is the same
    #     dd.timestamp                  # => '2012-01-02 12:34:56 CST'
    #
    # @example If the default is a literal nil it is set as normal:
    #
    #     Defaultable.field :might_be_nil, String, default: nil
    #     dd.attribute_set?(:might_be_nil) # => false
    #     dd.might_be_nil                  # => nil
    #     dd.attribute_set?(:might_be_nil) # => true
    #
    # If the default is generated from a block (or anything but a literal nil), no default is set:
    #
    #     Defaultable.field :might_be_nil,     String, default: ->{ puts 'ran!'; some_other_value ? some_other_value.reverse : nil }
    #     Defaultable.field :some_other_value, String
    #     dd = Defaultable.new
    #     dd.attribute_set?(:might_be_nil) # => false
    #     dd.might_be_nil                  # => nil
    #     'ran!'  # block was run
    #     dd.might_be_nil                  # => nil
    #     'ran!'  # block was run again
    #     dd.some_other_val = 'hello'
    #     dd.might_be_nil                  # => 'olleh'
    #     'ran!'  # block was run again, and set a value this time
    #     dd.some_other_val = 'goodbye'
    #     dd.might_be_nil                  # => 'olleh'
    #     # block was not run again
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to unset.
    # @return [Object] The new value
    def read_unset_attribute(field_name)
      field = self.class.fields[field_name] or return nil
      return unless field.has_default?
      val = attribute_default(field) 
      return nil if val.nil? && (not field.default.nil?) # don't write nil unless intent is clearly to have default nil 
      write_attribute(field.name, val)
    end


  protected

    # the actual default value to assign to the attribute
    def attribute_default(field)
      return unless field.has_default?
      val = field.default
      case
      when val.is_a?(Proc) && (val.arity == 0)
        self.instance_exec(&val)
      when val.is_a?(UnboundMethod) && (val.arity == 0)
        val.bind(self).call
      when val.respond_to?(:call)
        val.call(self, field.name)
      else
        val.try_dup
      end
    end

  end

end
