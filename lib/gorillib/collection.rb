require 'gorillib/metaprogramming/delegation'
require 'gorillib/metaprogramming/class_attribute'

module Gorillib

  #
  # The Collection class encapsulates the minimum functionality to let you:
  #
  # * store items uniquely, in order added
  # * retrieve items by label
  # * iterate over its values
  #
  # A collection is best used for representing 'plural' properties of models; it
  # is *not* intended to be some radical reimagining of a generic array or
  # hash. We've found its locked-down capabilities to particularly useful for
  # constructing DSLs (Domain-Specific Languages). Collections are *not*
  # intended to be performant: its abstraction layer comes at the price of
  # additional method calls.
  #
  # ### Gated admission
  #
  # Collection provides a well-defended perimeter. Every item added to the
  # collection (whether sent to the initializer, the  passes through `add` method
  #
  # ### Familiarity with its contents
  #
  # Typically your model will have a familiar (but not intimate) relationship
  # with its plural property:
  #
  # * items may have some intrinsic, uniquely-identifying feature: a `name`,
  #   `id`, or normalized representation. You'd like to be able to add an
  #   retrieve them by that intrinsic feature without having to manually juggle
  #   the correspondence of labels to intrinsic features.
  #
  # In the case of a ModelCollection,
  #
  # * all its items may share a common type: "a post has many `Comment`s".
  #
  # * a model may want items to hold a reference back to the containing model,
  #   or otherwise to share some common attributes. As an example, a `Graph` may
  #   have many `Stage` objects; the collection can inform newly-added stages
  #   which graph they belong to.
  #
  # ### Barebones enumerable methods
  #
  # The set of methods is purposefully sparse. If you want to use `select`,
  # `invert`, etc, just invoke `to_hash` or `to_a` and work with the copy it
  # gives you.
  #
  # Collection responds to:
  #   - receive!, values, to_a, each and each_value;
  #   - length, size, empty?, blank?
  #   - [], []=, include?, fetch, delete, each_pair, to_hash.
  #   - `key_method`: called on items to get their key; `to_key` by default.
  #   - `<<`: adds item under its `key_method` key
  #   - `receive!`s an array by auto-keying the elements, or a hash by trusting what you give it
  #
  # A ModelCollection adds:
  #   - `factory`: generates new items, converts received items
  #   - `update_or_create: if absent, creates item with given attributes and
  #     `key_method => key`; if present, updates with given attributes.
  #
  #
  class Collection
    # [{Symbol => Object}] The actual store of items, but not for you to mess with
    attr_reader :clxn
    protected   :clxn

    # [String, Symbol] Method invoked on a new item to generate its collection key; :to_key by default
    class_attribute :key_method, :instance_writer => false
    singleton_class.send(:protected, :key_method=)

    # include Gorillib::Model
    def initialize(options={})
      @clxn       = Hash.new
      @key_method = options[:key_method] if options.has_key?(:key_method)
    end

    # Adds an item in-place. Items added to the collection (via `add`, `[]=`,
    # `initialize`, etc) all pass through the `add` method: you should override
    # this in subclasses to add any gatekeeper behavior.
    #
    # If no label is supplied, we use the result of invoking `key_method` on the
    # item (or raise an error if no label *and* no key_method).
    #
    # It's up to you to ensure that labels make sense; this method doesn't
    # demand the item's key_method match its label.
    #
    # @return [Object] the item
    def add(item, label=nil)
      label ||= label_for(item)
      @clxn[label] = item
    end

    def label_for(item)
      if key_method.nil? then
        raise ArgumentError, "Can't add things to a #{self.class} without some sort of label: use foo[label] = obj, or set the collection's key_method" ;
      end
      item.public_send(key_method)
    end

    #
    # Barebones enumerable methods
    #
    # This set of methods is purposefully sparse. If you want to use `select`,
    # `invert`, etc, just invoke `to_hash` or `to_a` and work with the copy it
    # gives you.
    #

    delegate :[], :fetch, :delete, :include?,         :to => :clxn
    delegate :keys, :values, :each_pair, :each_value, :to => :clxn
    delegate :length, :size, :empty?, :blank?,        :to => :clxn

    # @return [Array] an array holding the items
    def to_a    ; values    ; end
    # @return [{Symbol => Object}] a hash of key=>item pairs
    def to_hash ; clxn.dup  ; end

    # iterate over each value in the collection
    def each(&block); each_value(&block) ; end

    # Adds item, returning the collection itself.
    # @return [Gorillib::Collection] the collection
    def <<(item)
      add(item)
      self
    end

    # add item with given label
    def []=(label, item)
      add(item, label)
    end

    # Receive items in-place, replacing any existing item with that label.
    #
    # Individual items are added using #receive_item -- if you'd like to perform
    # any conversion or modification to items, do it there
    #
    # @param  other [{Symbol => Object}, Array<Object>] a hash of key=>item pairs or a list of items
    # @return [Gorillib::Collection] the collection
    def receive!(other)
      if other.respond_to?(:each_pair)
        other.each_pair{|label, item| receive_item(label, item) }
      elsif other.respond_to?(:each)
        other.each{|item|             receive_item(nil,   item) }
      else
        raise "A collection can only receive something that is enumerable: got #{other.inspect}"
      end
      self
    end

    # items arriving from the outside world should pass through receive_item,
    # not directly to add.
    def receive_item(label, item)
      add(item, label)
    end

    # Create a new collection and add the given items to it
    def self.receive(items, *args)
      coll = new(*args)
      coll.receive!(items)
      coll
    end

    # A `native` object does not need any transformation; it is accepted directly.
    # By default, an object is native if it `is_a?` this class
    #
    # @param  obj [Object] the object that will be received
    # @return [true, false] true if the item does not need conversion
    def native?(obj)
      obj.is_a?(self)
    end

    # Two collections are equal if they have the same class and their contents are equal
    #
    # @param [Gorillib::Collection, Object] other The other collection to compare
    # @return [true, false] True if attributes are equal and other is instance of the same Class
    def ==(other)
      return false unless other.instance_of?(self.class)
      clxn == other.send(:clxn)
    end

    # @return [String] string describing the collection's array representation
    def to_s           ; to_a.to_s           ; end
    # @return [String] string describing the collection's array representation
    def inspect
      key_width = [keys.map{|key| key.to_s.length + 1 }.max.to_i, 45].min
      guts = clxn.map{|key, val| "%-#{key_width}s %s" % ["#{key}:", val.inspect] }.join(",\n   ")
      ['c{ ', guts, ' }'].join
    end

    def inspect_compact
      ['c{ ', keys.join(", "), ' }'].join
    end

  end
end
