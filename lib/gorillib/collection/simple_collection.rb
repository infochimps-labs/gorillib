require 'gorillib/metaprogramming/delegation'
require 'gorillib/metaprogramming/class_attribute'

module Gorillib
  class SimpleCollection
    # [{Symbol => Object}] The actual store of items, but not for you to mess with
    attr_reader :clxn
    protected   :clxn

    def initialize
      @clxn        = Array.new
    end

    def self.receive(items, *args)
      coll = new(*args)
      coll.receive!(items)
      coll
    end

    # common to all collections, delegable to all
    delegate :[], :[]=, :fetch,                :to => :clxn
    delegate :length, :size, :empty?, :blank?, :to => :clxn
    # common to all collections, delegable to array
    delegate :to_a, :each,                     :to => :clxn

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
    # Specfiic to Array-backed collections
    #

    # @return [Array] an array holding the items
    def values            ; to_a ; end

    # iterate over each value in the collection
    def each_value(&block); each(&block) ; end

    # Deletes the entry whose index is `idx`, returning the corresponding
    # value. If the index is out of bounds, returns nil. If the optional code
    # block is given and the index is out of bounds, pass it the index and
    # return the result of block.
    #
    # @return the now-delete value, if found; otherwise, the result of the
    #   block, if given; otherwise nil.
    def delete(idx, &block)
      if idx < length
        delete_at(idx)
      elsif block_given?
        yield(idx)
      else
        nil
      end
    end

    # Add the new items in-place; given items clobber existing items
    # @param  other [{Symbol => Object}, Array<Object>] a hash of key=>item pairs or a list of items
    # @return [Gorillib::Collection] the collection
    def receive!(other)
      clxn.concat( convert_collection(other) ).uniq!
      self
    end

  protected

    # - if the given collection responds_to `to_hash`, it is received into the internal collection; each hash key *must* match the id of its value or results are undefined.
    # - otherwise, it uses a hash generated from the id/value pairs of each object in the given collection.
    def convert_collection(cc)
      cc.values
    end
  end

end
