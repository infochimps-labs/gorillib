require 'gorillib/metaprogramming/delegation'
require 'gorillib/metaprogramming/class_attribute'

module Gorillib
  class Collection
    # [String, Symbol] Method invoked on a new item to generate its collection key; :to_key by default
    attr_accessor :key_method
    # The default `key_method` invoked on a new item to generate its collection key
    DEFAULT_KEY_METHOD = :to_key

    # [{Symbol => Object}] The actual store of items, but not for you to mess with
    attr_reader :clxn
    protected   :clxn

    def initialize(key_method=DEFAULT_KEY_METHOD)
      @clxn        = Hash.new
      @key_method  = key_method
    end

    def self.receive(items, *args)
      coll = new(*args)
      coll.receive!(items)
      coll
    end

    # common to all collections, delegable to all
    delegate :[], :[]=, :fetch,                       :to => :clxn
    delegate :length, :size, :empty?, :blank?,        :to => :clxn
    # common to all collections, delegable to hash
    delegate :values, :delete,                        :to => :clxn
    # novel to a labelled collection
    delegate :keys, :each_pair, :each_value,          :to => :clxn
    delegate :include?,                               :to => :clxn

    # Adds an item in-place
    # @return [Gorillib::Collection] the collection
    def <<(val)
      receive! [val]
      self
    end

    # Two collections are equal if they have the same class and their contents are equal
    #
    # @param [Gorillib::Collection, Object] other The other collection to compare
    # @return [true, false] True if attributes are equal and other is instance of the same Class
    def ==(other)
      return false unless other.instance_of?(self.class)
      clxn == other.send(:clxn)
    end

    #
    # Hash-backed collection
    #

    # @return [Array] an array holding the items
    def to_a    ; values    ; end
    # @return [{Symbol => Object}] a hash of key=>item pairs
    def to_hash ; clxn.dup  ; end

    # iterate over each value in the collection
    def each(&block); each_value(&block) ; end

    # Add the new items in-place; given items clobber existing items
    # @param  other [{Symbol => Object}, Array<Object>] a hash of key=>item pairs or a list of items
    # @return [Gorillib::Collection] the collection
    def receive!(other)
      clxn.merge!( convert_collection(other) )
      self
    end

  protected

    # - if the given collection responds_to `to_hash`, it is received into the internal collection; each hash key *must* match the id of its value or results are undefined.
    # - otherwise, it receives a hash generates from the id/value pairs of each object in the given collection.
    def convert_collection(cc)
      return cc.to_hash if cc.respond_to?(:to_hash)
      cc.inject({}) do |acc, val|
        key      = val.public_send(key_method)
        acc[key] = val
        acc
      end
    end

  public

    # @return [String] string describing the collection's array representation
    def to_s           ; to_a.to_s           ; end
    # @return [String] string describing the collection's array representation
    def inspect(detailed=true)
      str = "c{ "
      if detailed
        str << clxn.map do |key, val|
          "%-15s %s" % ["#{key}:", val.inspect]
        end.join(",\n   ")
      else
        str << keys.join(", ")
      end
      str << " }"
    end
    # @return [Array] serializable array representation of the collection
    def to_wire(options={})
      to_a.map{|el| el.respond_to?(:to_wire) ? el.to_wire(options) : el }
    end
    def as_json(*args) to_wire(*args) ; end

    # @return [String] JSON serialization of the collection's array representation
    def to_json(*args)
      to_wire(*args).to_json(*args)
    end

  end
end
