module Gorillib
  class Collection
    module HasCollection

      def has_collection(clxn_name, type, key_method=:name)
        plural_name   = clxn_name
        singular_name = Gorillib::Inflector.singularize(clxn_name.to_s).to_sym
        
        instance_variable_set("@#{plural_name}", Gorillib::Collection.new(type, key_method))

        define_singleton_method(plural_name) do
          instance_variable_get("@#{plural_name}") if instance_variable_defined?("@#{plural_name}")
        end

        define_singleton_method(singular_name) do |item_key, attrs={}, options={}, &block|
          collection = instance_variable_get("@#{clxn_name}")
          val = collection.fetch(item_key) do
            attrs.merge!(key_method => item_key, :owner => self) if attrs.respond_to?(:merge!)
            factory = options.fetch(:factory){ type }
            new_val = factory.receive(attrs)
            collection << new_val
            new_val
          end
          val.instance_exec(&block) if block
          val
        end
      end

    end
  end
end
