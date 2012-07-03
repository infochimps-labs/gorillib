require 'gorillib/metaprogramming/delegation'
require 'gorillib/metaprogramming/class_attribute'

module Gorillib

  #
  # A generic collection stores objects uniquely, in the order added. It responds to:
  #   - receive!, values, to_a, each and each_value;
  #   - length, size, empty?, blank?
  #
  # A Collection additionally lets you store and retrieve things by label:
  #   - [], []=, include?, fetch, delete, each_pair, to_hash.
  #
  # A ModelCollection adds:
  #   - `key_method`: called on objects to get their key; `to_key` by default.
  #   - `factory`: generates new objects, converts received objects
  #   - `<<`: adds object under its `key_method` key
  #   - `receive!`s an array by auto-keying the elements, or a hash by trusting what you give it
  #   - `update_or_create: if absent, creates object with given attributes and
  #     `key_method => key`; if present, updates with given attributes.
  #
  class GenericCollection
    # [{Symbol => Object}] The actual store of items, but not for you to mess with
    attr_reader :clxn
    protected   :clxn

    def self.receive(items, *args)
      coll = new(*args)
      coll.receive!(items)
      coll
    end

    delegate :length, :size, :empty?, :blank?, :to => :clxn

    # Two collections are equal if they have the same class and their contents are equal
    #
    # @param [Gorillib::Collection, Object] other The other collection to compare
    # @return [true, false] True if attributes are equal and other is instance of the same Class
    def ==(other)
      return false unless other.instance_of?(self.class)
      clxn == other.send(:clxn)
    end

  public

    # @return [String] string describing the collection's array representation
    def to_s           ; to_a.to_s           ; end
    # @return [String] string describing the collection's array representation
    def inspect(detailed=true)
      if detailed then  guts = clxn.map{|key, val| "%-15s %s" % ["#{key}:", val.inspect] }.join(",\n   ")
      else              guts =  keys.join(", ") ; end
      ["c{ ", guts, " }"].join
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

  class Collection < Gorillib::GenericCollection
    include Gorillib::Model
    def initialize
      @clxn   = Hash.new
    end

    delegate :[], :[]=, :fetch, :delete,       :to => :clxn
    delegate :values,                          :to => :clxn
    delegate :keys, :each_pair, :each_value,   :to => :clxn
    delegate :include?,                        :to => :clxn

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
      raise "a #{self.class} can only receive a hash with explicitly-labelled contents."
    end

  end
end
