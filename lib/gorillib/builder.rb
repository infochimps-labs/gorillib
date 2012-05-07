module Gorillib
  module Builder
    extend  Gorillib::Concern
    include Gorillib::Record

    def initialize(attrs={}, &block)
      receive!(attrs)
      instance_exec(&block) if block_given?
    end

    def getset(field, *args, &block)
      ArgumentError.check_arity!(args, 0..1)
      if args.empty?
        val = read_attribute(field.name)
      else
        val = write_attribute(field.name, args.first)
      end
      val
    end

    def getset_member(field, *args, &block)
      val = read_attribute(field.name)
      if val.blank? && args.blank?
        return nil
      elsif val.blank?
        val = field.type.receive(*args)
        write_attribute(field.name, val)
      else
        val.receive!(*args) if args.present?
      end
      if block_given?
        (block.arity == 1) ? block.call(val) : val.instance_eval(&block)
      end
      val
    end

    def key_method
      :name
    end

    def getset_collection_item(field, item_key, attrs={}, &block)
      val = read_collection_item(field.name, item_key)
      if val.blank?
        val = add_collection_item(field, item_key, attrs)
      else
        val.receive!(attrs) if attrs.present?
      end
      if block_given?
        (block.arity == 1) ? block.call(val) : val.instance_eval(&block)
      end
      val
    end

    def collection_of(plural_name)
      self.read_attribute(plural_name)
    end

    def add_collection_item(field, item_key=nil, attrs={}, &block)
      attrs.merge!(key_method => item_key, self.class.handle => self)
      val = field.type.receive(attrs)
      collection_of(field.name) << val
      val
    end

    def read_collection_item(clxn_name, item_key, *args)
      item = collection_of(clxn_name)[item_key]
    end

    module ClassMethods

      #
      # Receive external data, type-converting and creating contained records as necessary
      #
      # @return [Gorillib::Record] the new object
      def receive(*args, &block)
        return nil        if args.present? && args.first.nil?
        return args.first if args.present? && args.first.is_a?(self)
        new(*args, &block)
      end

      def regular_field(*args)
        _field(*args)
      end

      def field(field_name, type, options={})
        _field(field_name, type, options.merge(:field_type => ::Gorillib::Builder::GetsetField))
      end

      def member(field_name, type, options={})
        _field(field_name, type, options.merge(:field_type => ::Gorillib::Builder::MemberField))
      end

      def collection(field_name, type, options={})
        _field(field_name, type, options.merge(:field_type => ::Gorillib::Builder::CollectionField))
      end
    end
  end

  module FancyBuilder
    extend  Gorillib::Concern
    include Gorillib::Builder

    module ClassMethods
      def belongs_to(field_name, type, options={})
        field = _field(field_name, type, options.merge(:field_type => ::Gorillib::Builder::MemberField))
        define_meta_module_method "#{field.name}_name" do
          val = getset_member(field) or return nil
          val.name
        end
        field
      end

      def handle
        Gorillib::Inflector.underscore(Gorillib::Inflector.demodulize(self.name)).to_sym
      end
    end
  end

  module Builder
    class CollectionField < Gorillib::Record::Field
      field :singular_name, Symbol, :default => ->{ Gorillib::Inflector.singularize(name.to_s).to_sym }

      alias_method :plural_name, :name
      def singular_name
        @singular_name ||= Gorillib::Inflector.singularize(name.to_s).to_sym
      end

      def collection_key
        :name
      end

      #
      #
      #
      def inscribe_methods(record)
        fn   = self.name
        type = self.type
        field = self
        plural_name = self.plural_name
        singular_name = self.singular_name
        collection_key = self.collection_key

        self.default = ->{ Gorillib::Collection.new(type, collection_key) }

        record.__send__(:define_meta_module_method, plural_name,     visibility(:reader)  ) do
          read_attribute(plural_name)
        end
        record.__send__(:define_meta_module_method, singular_name,   visibility(:reader)  ) do |*args, &block|
          getset_collection_item(field, *args, &block)
        end
        record.__send__(:define_meta_module_method, "has_#{singular_name}?", visibility(:reader)  ) do |item_key|
          collection_of(plural_name).include?(item_key)
        end
        record.__send__(:define_meta_module_method, "receive_#{fn}", visibility(:receiver)) do |val|
          val = type.receive(val)
          write_attribute(fn, val)
          self
        end
      end
    end


    class GetsetField < Gorillib::Record::Field
      #
      #
      #
      def inscribe_methods(record)
        fn   = self.name
        type = self.type
        field = self
        record.__send__(:define_meta_module_method, fn,              visibility(:reader)  ) do |*args, &block|
          getset(field, *args, &block)
        end
        record.__send__(:define_meta_module_method, "receive_#{fn}", visibility(:receiver)) do |val|
          val = type.receive(val)
          write_attribute(fn, val)
          self
        end
      end
    end

    class MemberField < Gorillib::Record::Field
      #
      #
      #
      def inscribe_methods(record)
        fn   = self.name
        type = self.type
        field = self

        record.__send__(:define_meta_module_method, fn,              visibility(:reader)  ) do |*args, &block|
          getset_member(field, *args, &block)
        end
        record.__send__(:define_meta_module_method, "receive_#{fn}", visibility(:receiver)) do |val|
          val = type.receive(val)
          write_attribute(fn, val)
          self
        end
      end
    end

  end
end
