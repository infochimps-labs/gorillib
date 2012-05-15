require 'gorillib/string/simple_inflector'
require 'gorillib/model'
require 'gorillib/model/field'
require 'gorillib/model/defaults'

module Gorillib
  module Builder
    extend  Gorillib::Concern
    include Gorillib::Model

    def initialize(attrs={}, &block)
      receive!(attrs, &block)
    end

    def receive!(*args, &block)
      super(*args)
      if block_given?
        (block.arity == 1) ? block.call(self) : self.instance_eval(&block)
      end
      self
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
      ArgumentError.check_arity!(args, 0..1)
      attrs = args.first
      if attrs.is_a?(field.type)        # actual object: assign it into field
        val = attrs
        write_attribute(field.name, val)
      elsif attribute_set?(field.name)  # existing item: retrieve it, updating as directed
        val = read_attribute(field.name)
        val.receive!(*args, &block)
      elsif attrs.blank?                # missing item (read): return nil
        return nil
      else                              # missing item (write): construct item and add to collection
        val = field.type.receive(*args, &block)
        write_attribute(field.name, val)
      end
      val
    end

    def getset_collection_item(field, item_key, attrs={}, &block)
      clxn = collection_of(field.plural_name)
      if attrs.is_a?(field.type)     # actual object: assign it into collection
        val = attrs
        clxn[item_key] = val
      elsif clxn.include?(item_key)  # existing item: retrieve it, updating as directed
        val = clxn[item_key]
        val.receive!(attrs, &block)
      else                           # missing item: autovivify item and add to collection
        val = field.type.receive({ key_method => item_key, :owner => self }.merge(attrs), &block)
        clxn[item_key] = val
      end
      val
    end

    def key_method
      :name
    end

    def collection_of(plural_name)
      self.read_attribute(plural_name)
    end

    module ClassMethods

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

      def collects(type, clxn_name)
        type_handle = type.handle
        define_meta_module_method type_handle do |item_name, attrs={}, options={}, &block|
          send(clxn_name, item_name, attrs, options.merge(:factory => type), &block)
        end
      end
    end
  end

  module Builder
    class CollectionField < Gorillib::Model::Field
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

      def inscribe_methods(model)
        type           = self.type
        collection_key = self.collection_key
        self.default   = ->{ Gorillib::Collection.new(type, collection_key) }
        #
        raise "Plural and singular names must differ: #{self.plural_name}" if (singular_name == plural_name)
        #
        @visibilities[:writer] = false
        super
        model.__send__(:define_collection_getset,  self)
        model.__send__(:define_collection_tester,  self)
      end
    end

    class GetsetField < Gorillib::Model::Field
      self.visibilities = visibilities.merge(:writer => false, :tester => false)

      def inscribe_methods(model)
        @visibilities[:writer] = false
        super
        model.__send__(:define_attribute_getset,  self)
      end
    end

    class MemberField < Gorillib::Model::Field
      self.visibilities = visibilities.merge(:writer => false, :tester => true)

      def inscribe_methods(model)
        @visibilities[:writer] = false
        super
        model.__send__(:define_member_getset,  self)
      end
    end

  end
end
