module Gorillib

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
      if label && include?(label)
        item = fetch(label)
        item.receive!(attrs, &block)
        item
      else
        attrs = attrs.attributes if attrs.is_a? Gorillib::Model
        attrs = attrs.merge(key_method => label) if key_method && label
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
        @common_attrs = self.common_attrs.merge(options[:common_attrs]) if options.include?(:common_attrs)
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

    #
    # @example
    #   class Smurf
    #     include Gorillib::Model
    #   end
    #
    #   # Sets the 'village' attribute on each item it receives to the object
    #   # this collection belongs to.
    #   class SmurfCollection < ModelCollection
    #     include Gorillib::Collection::ItemsBelongTo
    #     self.item_type        = Smurf
    #     self.parentage_method = :village
    #   end
    #
    #   # SmurfVillage makes sure its SmurfCollection knows that it `belongs_to` the village
    #   class SmurfVillage
    #     include Gorillib::Model
    #     field :name,   Symbol
    #     field :smurfs, SmurfCollection, default: ->{ SmurfCollection.new(belongs_to: self) }
    #   end
    #
    #   # all the normal stuff works as you'd expect
    #   smurf_town = SmurfVillage.new('smurf_town')   # #<SmurfVillage name=smurf_town>
    #   smurf_town.smurfs                             # c{ }
    #   smurf_town.smurfs.belongs_to                  # #<SmurfVillage name=smurf_town>
    #
    #   # when a new smurf moves to town, it knows what village it belongs_to
    #   smurf_town.smurfs.receive_item(:novel_smurf, smurfiness: 10)
    #   # => #<Smurf name=:novel_smurf smurfiness=10 village=#<SmurfVillage name=smurf_town>>
    #
    module ItemsBelongTo
      extend Gorillib::Concern
      include Gorillib::Collection::CommonAttrs

      included do
        # [Class, #receive] Name of the attribute to set on
        class_attribute :parentage_method, :instance_writer => false
        singleton_class.send(:protected, :common_attrs=)
      end

      # add this collection's belongs_to to the common attrs, so that a
      # newly-created object knows its parentage from birth.
      def initialize(*args)
        super
        @common_attrs = self.common_attrs.merge(parentage_method => self.belongs_to)
      end

      def add(item, *args)
        item.send("#{parentage_method}=", belongs_to)
        super
      end

    end

  end
end
