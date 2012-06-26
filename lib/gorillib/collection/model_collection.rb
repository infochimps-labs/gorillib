module Gorillib
  class ModelCollection < Gorillib::Collection
    # [String, Symbol] Method invoked on a new item to generate its collection key; :to_key by default
    attr_accessor :key_method
    # The default `key_method` invoked on a new item to generate its collection key
    DEFAULT_KEY_METHOD = :to_key

    # [Class, #receive] Factory for generating a new collection item.
    class_attribute :factory, :instance_writer => false
    singleton_class.class_eval{ protected :factory= }

    def initialize(key_meth=nil, obj_factory=nil)
      @factory     = Gorillib::Factory(obj_factory) if obj_factory
      @clxn        = Hash.new
      @key_method  = key_meth || DEFAULT_KEY_METHOD
    end

    # Adds an item in-place
    # @return [Gorillib::Collection] the collection
    def <<(val)
      receive! [val]
      self
    end

    def create(*args, &block)
      item = factory.receive(*args)
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
      return val unless factory
      return nil if val.nil?
      factory.receive(val)
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
