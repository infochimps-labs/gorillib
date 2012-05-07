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

    def getset_collection_item(field, item_key, attrs={}, options={}, &block)
      val = read_collection_item(field.name, item_key)
      if val.blank?
        val = add_collection_item(field, item_key, attrs, options)
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

    def add_collection_item(field, item_key=nil, attrs={}, options={}, &block)
      attrs.merge!(key_method => item_key) if attrs.respond_to?(:merge!)
      factory = options.fetch(:factory){ field.type }
      val = factory.receive(attrs)
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

      # KLUDGE: no smell good, this
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
      # /KLUDGE

    protected

      def define_attribute_getset(field)
        define_meta_module_method(field.name, field.visibility(:reader)) do |*args, &block|
          getset(field, *args, &block)
        end
      end

      def define_member_getset(field)
        define_meta_module_method(field.name, field.visibility(:reader)) do |*args, &block|
          getset_member(field, *args, &block)
        end
      end

      def define_collection_getset(field)
        define_meta_module_method(field.singular_name, field.visibility(:collection_getset)) do |*args, &block|
          getset_collection_item(field, *args, &block)
        end
      end

      def define_collection_tester(field)
        plural_name = field.plural_name
        define_meta_module_method("has_#{field.singular_name}?", field.visibility(:collection_tester)) do |item_key|
          collection_of(plural_name).include?(item_key)
        end
      end

    end
  end

  module FancyBuilder
    extend  Gorillib::Concern
    include Gorillib::Builder

    def add_collection_item(field, item_key=nil, attrs={}, options={}, &block)
      super(field, item_key, attrs.merge(self.class.handle => self), options, &block)
    end

    def inspect(detailed=true)
      str = super
      detailed ? str : ([str[0..-2], " #{read_attribute(key_method)}>"].join)
    end

    included do |base|
      base.field :name,  Symbol
    end

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


      def collects(type, clxn_name)
        type_handle = type.handle
        define_meta_module_method type_handle do |item_name, attrs={}, options={}, &block|
          send(clxn_name, item_name, attrs.merge(:owner => self), options.merge(:factory => type), &block)
        end
      end
    end
  end

  module Builder
    class CollectionField < Gorillib::Record::Field
      field :singular_name, Symbol, :default => ->{ Gorillib::Inflector.singularize(name.to_s).to_sym }

      self.visibilities = visibilities.merge(:writer => false, :tester => false,
        :collection_getset => :public, :collection_tester => true)

      alias_method :plural_name, :name
      def singular_name
        @singular_name ||= Gorillib::Inflector.singularize(name.to_s).to_sym
      end

      def collection_key
        :name
      end

      def inscribe_methods(record)
        type           = self.type
        collection_key = self.collection_key
        self.default   = ->{ Gorillib::Collection.new(type, collection_key) }
        #
        @visibilities[:writer] = false
        super
        record.__send__(:define_collection_getset,  self)
        record.__send__(:define_collection_tester,  self)
      end
    end

    class GetsetField < Gorillib::Record::Field
      self.visibilities = visibilities.merge(:writer => false, :tester => false)

      def inscribe_methods(record)
        @visibilities[:writer] = false
        super
        record.__send__(:define_attribute_getset,  self)
      end
    end

    class MemberField < Gorillib::Record::Field
      self.visibilities = visibilities.merge(:writer => false, :tester => true)

      def inscribe_methods(record)
        @visibilities[:writer] = false
        super
        record.__send__(:define_member_getset,  self)
      end
    end

  end
end
