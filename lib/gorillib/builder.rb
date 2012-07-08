require 'gorillib/string/simple_inflector'
require 'gorillib/model'
require 'gorillib/collection/model_collection'

module Gorillib
  module Builder
    extend  Gorillib::Concern
    include Gorillib::Model

    # @return [Object, nil] the return value of the block, or nil if no block given
    def receive!(*args, &block)
      super(*args)
      if block_given?
        (block.arity == 1) ? block.call(self) : self.instance_eval(&block)
      end
    end

    def getset(field, *args, &block)
      ArgumentError.check_arity!(args, 0..1)
      if args.empty?
        read_attribute(field.name)
      else
        write_attribute(field.name, args.first)
      end
    end

    def getset_member(field, *args, &block)
      ArgumentError.check_arity!(args, 0..1)
      attrs = args.first
      if attrs.is_a?(field.type)
        # actual object: assign it into field
        val = attrs
        write_attribute(field.name, val)
      else
        val = read_attribute(field.name)
        if val.present?
          # existing item: update it with args and block
          val.receive!(*args, &block) if args.present?
        elsif attrs.blank?
          # missing item (read): return nil
          return nil
        else
          # missing item (write): construct item and add to collection
          options = args.extract_options!.merge(:owner => self)
          val = field.type.receive(*args, options, &block)
          write_attribute(field.name, val)
        end
      end
      val
    end

    def getset_collection_item(field, item_key, attrs={}, &block)
      plural_name = field.plural_name
      if attrs.is_a?(field.item_type)
        # actual object: assign it into collection
        val = attrs
        set_collection_item(plural_name, item_key, val)
      elsif has_collection_item?(plural_name, item_key)
        # existing item: retrieve it, updating as directed
        val = get_collection_item(plural_name, item_key)
        val.receive!(attrs, &block)
      else
        # missing item: autovivify item and add to collection
        val = field.item_type.receive({ key_method => item_key, :owner => self }.merge(attrs), &block)
        set_collection_item(plural_name, item_key, val)
      end
      val
    end

    def get_collection_item(plural_name, item_key)
      collection_of(plural_name)[item_key]
    end

    def set_collection_item(plural_name, item_key, item)
      collection = collection_of(plural_name)
      collection[item_key] = item
      collection[item_key]
    end

    def has_collection_item?(plural_name, item_key)
      collection_of(plural_name).include?(item_key)
    end

    def key_method
      :name
    end

    def to_key
      self.read_attribute(key_method)
    end

    def inspect_helper(detailed, attrs)
      attrs.delete(:owner)
      # detailed ? str : ([str[0..-2], " #{to_key}>"].join)
      str = super(detailed, attrs)
    end

    def collection_of(plural_name)
      self.read_attribute(plural_name)
    end

    module ClassMethods
      include Gorillib::Model::ClassMethods

      def magic(field_name, type, options={})
        field(field_name, type, {:field_type => ::Gorillib::Builder::GetsetField}.merge(options))
      end
      def member(field_name, type, options={})
        field(field_name, type, {:field_type => ::Gorillib::Builder::MemberField}.merge(options))
      end
      def collection(field_name, item_type, options={})
        field(field_name, Gorillib::ModelCollection, {
            :item_type => item_type,
            :field_type => ::Gorillib::Builder::CollectionField}.merge(options))
      end

    protected

      def define_attribute_getset(field)
        field_name = field.name; type = field.type
        define_meta_module_method(field_name, field.visibility(:reader)) do |*args, &block|
          begin
            getset(field, *args, &block)
          rescue StandardError => err ; err.polish("#{self.class}.#{field_name} type #{type} on #{args}'") rescue nil ; raise ; end
        end
      end

      def define_member_getset(field)
        field_name = field.name; type = field.type
        define_meta_module_method(field_name, field.visibility(:reader)) do |*args, &block|
          begin
            getset_member(field, *args, &block)
          rescue StandardError => err ; err.polish("#{self.class}.#{field_name} type #{type} on #{args}'") rescue nil ; raise ; end
        end
      end

      def define_collection_getset(field)
        field_name = field.name; item_type = field.item_type
        define_meta_module_method(field.singular_name, field.visibility(:collection_getset)) do |*args, &block|
          begin
            getset_collection_item(field, *args, &block)
          rescue StandardError => err ; err.polish("#{self.class}.#{field_name} c[#{item_type}] on #{args}'") rescue nil ; raise ; end
        end
      end

      def define_collection_receiver(field)
        plural_name = field.name; item_type = field.item_type; field_type = field.type
        define_meta_module_method("receive_#{plural_name}", true) do |coll, &block|
          begin
            if coll.is_a?(field_type)
              write_attribute(plural_name, coll)
            else
              read_attribute(plural_name).receive!(coll, &block)
            end
            self
          rescue StandardError => err ; err.polish("#{self.class} #{plural_name} c[#{item_type}] on #{args}'") rescue nil ; raise ; end
        end
      end

      def define_collection_tester(field)
        plural_name = field.plural_name
        define_meta_module_method("has_#{field.singular_name}?", field.visibility(:collection_tester)) do |item_key|
          begin
            collection_of(plural_name).include?(item_key)
          rescue StandardError => err ; err.polish("#{self.class}.#{plural_name} having #{item_key}?'") rescue nil ; raise ; end
        end
      end

    end
  end

  module FancyBuilder
    extend  Gorillib::Concern
    include Gorillib::Builder

    included do |base|
      base.magic :name,  Symbol
    end

    module ClassMethods
      include Gorillib::Builder::ClassMethods

      def belongs_to(field_name, type, options={})
        field = member(field_name, type)
        define_meta_module_method "#{field.name}_name" do
          val = getset_member(field) or return nil
          val.name
        end
        field
      end

      def option(field_name, options={})
        type = options.delete(:type){ Whatever }
        magic(field_name, type)
      end

      def collects(type, clxn_name)
        type_handle = type.handle
        define_meta_module_method type_handle do |item_name, attrs={}, options={}, &block|
          send(clxn_name, item_name, attrs, options.merge(:factory => type), &block)
        end
      end
    end
  end

  module Builder

    class GetsetField < Gorillib::Model::Field
      self.visibilities = visibilities.merge(:writer => false, :tester => false, :getset => true)
      def inscribe_methods(model)
        model.__send__(:define_attribute_getset,   self)
        model.__send__(:define_attribute_writer,   self.name, self.type, visibility(:writer))
        model.__send__(:define_attribute_tester,   self.name, self.type, visibility(:tester))
        model.__send__(:define_attribute_receiver, self.name, self.type, visibility(:receiver))
      end
    end

    class MemberField < Gorillib::Model::Field
      self.visibilities = visibilities.merge(:writer => false, :tester => true)
      def inscribe_methods(model)
        model.__send__(:define_member_getset,      self)
        model.__send__(:define_attribute_writer,   self.name, self.type, visibility(:writer))
        model.__send__(:define_attribute_tester,   self.name, self.type, visibility(:tester))
        model.__send__(:define_attribute_receiver, self.name, self.type, visibility(:receiver))
      end
    end

    class CollectionField < Gorillib::Model::Field
      field :singular_name, Symbol, :default => ->{ Gorillib::Inflector.singularize(name.to_s).to_sym }
      field :item_type, Class, :default => Whatever

      self.visibilities = visibilities.merge(:writer => false, :tester => false,
        :collection_getset => :public, :collection_tester => true)

      alias_method :plural_name, :name
      def singular_name
        @singular_name ||= Gorillib::Inflector.singularize(name.to_s).to_sym
      end

      def inscribe_methods(model)
        item_type      = self.item_type
        self.default   = ->{ Gorillib::ModelCollection.new(key_method: key_method, item_type: item_type) }
        raise "Plural and singular names must differ: #{self.plural_name}" if (singular_name == plural_name)
        #
        @visibilities[:writer] = false
        model.__send__(:define_attribute_reader,   self.name, self.type, visibility(:reader))
        model.__send__(:define_attribute_tester,   self.name, self.type, visibility(:tester))
        #
        model.__send__(:define_collection_receiver, self)
        model.__send__(:define_collection_getset,   self)
        model.__send__(:define_collection_tester,   self)
      end
    end

  end
end
