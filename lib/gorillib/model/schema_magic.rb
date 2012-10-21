module Gorillib
  module Model

    module ClassMethods

      # Defines a new field
      #
      # For each field that is defined, a getter and setter will be added as
      # an instance method to the model. An Field instance will be added to
      # result of the fields class method.
      #
      # @example
      #   field :height, Integer
      #
      # @param [Symbol] field_name             The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]`
      # @param [Class]  type                   The field's type (required)
      # @option options [String] doc           Documentation string for the field (optional)
      # @option options [Proc, Object] default Default value, or proc that instance can evaluate to find default value
      #
      # @return Gorillib::Model::Field
      def field(field_name, type, options={})
        options = options.symbolize_keys
        field_type = options.delete(:field_type){ ::Gorillib::Model::Field }
        fld = field_type.new(self, field_name, type, options)
        @_own_fields[fld.name] = fld
        _reset_descendant_fields
        fld.send(:inscribe_methods, self)
        fld
      end

      def collection(field_name, collection_type, options={})
        options[:item_type] = options[:of] if options.has_key?(:of)
        field(field_name, collection_type, {
            field_type: ::Gorillib::Model::SimpleCollectionField}.merge(options))
      end

      # @return [{Symbol => Gorillib::Model::Field}]
      def fields
        return @_fields if defined?(@_fields)
        @_fields = ancestors.reverse.inject({}){|acc, ancestor| acc.merge!(ancestor.try(:_own_fields) || {}) }
      end

      # @return [true, false] true if the field is defined on this class
      def has_field?(field_name)
        fields.has_key?(field_name)
      end

      # @return [Array<Symbol>] The attribute names
      def field_names
        @_field_names ||= fields.keys
      end

      def positionals
        @_positionals ||= assemble_positionals
      end

      def assemble_positionals
        positionals = fields.values.keep_if{|fld| fld.position? }.sort_by!{|fld| fld.position }
        return [] if positionals.empty?
        if (positionals.map(&:position) != (0..positionals.length-1).to_a) then raise ConflictingPositionError, "field positions #{positionals.map(&:position).join(",")} for #{positionals.map(&:name).join(",")} aren't in strict minimal order"  ; end
        positionals.map!(&:name)
      end

      # turn model constructor args (`*positional_args, {attrs}`) into a combined
      # attrs hash. positional_args are mapped to the set of attribute names in
      # order -- by default, the class' field names.
      #
      # Notes:
      #
      # * Positional args always clobber elements of the attribute hash.
      # * Nil positional args are treated as present-and-nil (this might change).
      # * Raises an error if positional args
      #
      # @param [Array[Symbol]] args list of attributes, in order, to map.
      #
      # @return [Hash] a combined, reconciled hash of attributes to set
      def attrs_hash_from_args(args)
        attrs = args.extract_options!
        if args.present?
          ArgumentError.check_arity!(args, 0..positionals.length){ "extracting args #{args} for #{self}" }
          positionals_to_map = positionals[0..(args.length-1)]
          attrs = attrs.merge(Hash[positionals_to_map.zip(args)])
        end
        attrs
      end

    protected

      attr_reader :_own_fields

      # Ensure that classes inherit all their parents' fields, even if fields
      # are added after the child class is defined.
      def _reset_descendant_fields
        ObjectSpace.each_object(::Class) do |klass|
          klass.__send__(:remove_instance_variable, '@_fields')      if (klass <= self) && klass.instance_variable_defined?('@_fields')
          klass.__send__(:remove_instance_variable, '@_field_names') if (klass <= self) && klass.instance_variable_defined?('@_field_names')
          klass.__send__(:remove_instance_variable, '@_positionals') if (klass <= self) && klass.instance_variable_defined?('@_positionals')
        end
      end

      # define the reader method `#foo` for a field named `:foo`
      def define_attribute_reader(field_name, field_type, visibility)
        define_meta_module_method(field_name, visibility) do
          begin
            read_attribute(field_name)
          rescue StandardError => err ; err.polish("#{self.class}.#{field_name}") rescue nil ; raise ; end
        end
      end

      # define the writer method `#foo=` for a field named `:foo`
      def define_attribute_writer(field_name, field_type, visibility)
        define_meta_module_method("#{field_name}=", visibility) do |val|
          write_attribute(field_name, val)
        end
      end

      # define the present method `#foo?` for a field named `:foo`
      def define_attribute_tester(field_name, field_type, visibility)
        field = fields[field_name]
        define_meta_module_method("#{field_name}?", visibility) do
          attribute_set?(field_name) || field.has_default?
        end
      end

      def define_attribute_receiver(field_name, field_type, visibility)
        # @param  [Object] val the raw value to type-convert and adopt
        # @return [Object] the attribute's new value
        define_meta_module_method("receive_#{field_name}", visibility) do |val|
          begin
            val = field_type.receive(val)
            write_attribute(field_name, val)
          rescue StandardError => err ; err.polish("#{self.class}.#{field_name} type #{type} on #{val}") rescue nil ; raise ; end
        end
      end

      #
      # Collection receiver --
      #
      def define_collection_receiver(field)
        collection_field_name = field.name; collection_type = field.type
        # @param  [Array[Object],Hash[Object]] the collection to merge
        # @return [Gorillib::Collection] the updated collection
        define_meta_module_method("receive_#{collection_field_name}", true) do |coll, &block|
          begin
            if collection_type.native?(coll)
              write_attribute(collection_field_name, coll)
            else
              read_attribute(collection_field_name).receive!(coll, &block)
            end
          rescue StandardError => err ; err.polish("#{self.class} #{collection_field_name} collection on #{args}'") rescue nil ; raise ; end
        end
      end

      def inherited(base)
        base.instance_eval do
          self.meta_module
          @_own_fields ||= {}
        end
        super
      end
    end
  end
end
