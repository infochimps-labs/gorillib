require 'gorillib/collection'

module Gorillib
  class ListCollection < Gorillib::GenericCollection

    def initialize
      @clxn = Array.new
    end
    
    # common to all collections, delegable to array
    delegate :to_a, :each,         :to => :clxn

    # Add the new items in-place; given items clobber existing items
    # @param  other [{Symbol => Object}, Array<Object>] a hash of key=>item pairs or a list of items
    # @return [Gorillib::Collection] the collection
    def receive!(other)
      clxn.concat( convert_collection(other) ).uniq!
      self
    end

    # @return [Array] an array holding the items
    def values ; to_a ; end

    # iterate over each value in the collection
    def each_value(&block); each(&block) ; end

    # # removed on purpose, pending us understanding what the
    # # even-yet-simpler-still collection should be.
    #
    # delegate :[], :[]=, :fetch,    :to => :clxn
    #
    # # Deletes the entry whose index is `idx`, returning the corresponding
    # # value. If the index is out of bounds, returns nil. If the optional code
    # # block is given and the index is out of bounds, pass it the index and
    # # return the result of block.
    # #
    # # @return the now-delete value, if found; otherwise, the result of the
    # #   block, if given; otherwise nil.
    # def delete(idx, &block)
    #   if idx < length
    #     clxn.delete_at(idx)
    #   elsif block_given?
    #     yield(idx)
    #   else
    #     nil
    #   end
    # end

  protected

    # - if the given collection responds_to `to_hash`, it is received into the internal collection; each hash key *must* match the id of its value or results are undefined.
    # - otherwise, it uses a hash generated from the id/value pairs of each object in the given collection.
    def convert_collection(cc)
      cc.respond_to?(:values) ? cc.values : cc.to_a
    end
  end

end
