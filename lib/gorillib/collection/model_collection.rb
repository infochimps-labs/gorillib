module Gorillib


  #
  # facet(:foo)                        -- update_or_add facet
  # facet(:foo, :blah => 'val')        -- update_or_add facet
  # facet(:foo, :blah => 'val'){ ... } -- update_or_add facet
  #
  # facet(:foo, existing_facet)        -- error
  #

  class Collection
    #
    #
    #     class ClusterCollection < ModelCollection
    #       self.item_type = Cluster
    #     end
    #     class Organization
    #       field :clusters, ClusterCollection, default: ->{ ClusterCollection.new(common_attrs: { organization: self }) }
    #     end
    #
    module CommonAttrs
      extend Gorillib::Concern

      included do
        # [Class, #receive] Attributes to mix in to each added item
        class_attribute :common_attrs, :instance_writer => false
        singleton_class.send(:protected, :common_attrs=)
        self.common_attrs = Hash.new
      end

      def initialize(options={})
        super
        @common_attrs = self.class.common_attrs.merge(options[:common_attrs]) if options.include?(:common_attrs)
      end

      #
      # * a factory-native object: item is updated with common_attrs, then added
      # * raw materials for the object: item is constructed (from the merged attrs and common_attrs), then added
      #
      def receive_item(label, *args, &block)
        attrs = args.extract_options!.merge(common_attrs)
        super(label, *args, attrs, &block)
      end

      def update_or_add(label, *args, &block)
        attrs = args.extract_options!.merge(common_attrs)
        super(label, *args, attrs, &block)
      end

    end
  end

  #
  # A collection of Models
  #
  # ### Item Type
  #
  # `item_type` is a class attribute -- you can make a "collection of Foo's" by
  # subclassing ModelCollection and set the item item_type at the class level:
  #
  #     class ClusterCollection < ModelCollection
  #       self.item_type = Cluster
  #     end
  #
  #
  #
  # A model collection serializes as an array does, but indexes labelled objects
  # as a hash does.
  #
  #
  class ModelCollection < Gorillib::Collection
    # [Class, #receive] Factory for generating a new collection item.
    class_attribute :item_type, :instance_writer => false
    singleton_class.send(:protected, :item_type=)

    def initialize(options={})
      @item_type  = Gorillib::Factory(options[:item_type]) if options[:item_type]
      super
    end

    def receive_item(label, *args, &block)
      item  = item_type.receive(*args, &block)
      super(label, item)
    rescue StandardError => err ; err.polish("#{item_type} #{label} as #{args.inspect} to #{self}") rescue nil ; raise
    end

    def update_or_add(label, attrs, &block)
      if include?(label)
        item = fetch(label)
        item.receive!(attrs, &block)
        item
      else
        attrs = attrs.merge(key_method => label) if key_method
        receive_item(label, attrs, &block)
      end
    rescue StandardError => err ; err.polish("#{item_type} #{label} as #{attrs} to #{self}") rescue nil ; raise
    end

    # @return [Array] serializable array representation of the collection
    def to_wire(options={})
      to_a.map{|el| el.respond_to?(:to_wire) ? el.to_wire(options) : el }
    end
    # same as #to_wire
    def as_json(*args) to_wire(*args) ; end
    # @return [String] JSON serialization of the collection's array representation
    def to_json(*args) to_wire(*args).to_json(*args) ; end
  end

  #
  # Deprecated!
  #

  class ModelCollectionOld < Gorillib::ModelCollection
    # The default `key_method` invoked on a new item to generate its collection key
    DEFAULT_KEY_METHOD = :to_key

    def initialize(key_meth=nil, item_type=nil)
      @item_type   = Gorillib::Factory(item_type) if item_type
      @clxn        = Hash.new
      @key_method  = key_meth || DEFAULT_KEY_METHOD
    end

    def create(*args, &block)
      item = item_type.receive(*args)
      self << item
      item
    end

    def update_or_create(key, *args, &block)
      if include?(key)
        obj = fetch(key)
        obj.receive!(*args, &block)
        obj
      else
        attrs = args.extract_options!.merge(key_method => key)
        create(*args, attrs, &block)
      end
    end

  protected

    def convert_value(val)
      return val unless item_type
      return nil if val.nil?
      item_type.receive(val)
    end

    # - if the given collection responds_to `to_hash`, it is received into the internal collection; each hash key *must* match the id of its value or results are undefined.
    # - otherwise, it receives a hash generates from the id/value pairs of each object in the given collection.
    def convert_collection(cc)
      return cc.to_hash if cc.respond_to?(:to_hash)
      cc.inject({}) do |acc, val|
        val      = convert_value(val)
        key      = val.public_send(key_method)
        acc[key] = val
        acc
      end
    end

  end
end
