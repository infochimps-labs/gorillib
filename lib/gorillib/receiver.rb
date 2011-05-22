# dummy type for receiving True or False
class Boolean ; end unless defined?(Boolean)

# Receiver lets you describe complex (even recursive!) actively-typed data models that
# * are creatable or assignable from static data structures
# * perform efficient type conversion when assigning from a data structure,
# * but with nothing in the way of normal assignment or instantiation
# * and no requirements on the initializer
#
#    class Tweet
#      include Receiver
#      rcvr_accessor :id,           Integer
#      rcvr_accessor :user_id,      Integer
#      rcvr_accessor :created_at,   Time
#    end
#    p Tweet.receive(:id => "7", :user_id => 9, :created_at => "20101231010203" )
#     # => #<Tweet @id=7, @user_id=9, @created_at=2010-12-31 07:02:03 UTC>
#
# You can override receive behavior in a straightforward and predictable way:
#
#    class TwitterUser
#      include Receiver
#      rcvr_accessor :id,           Integer
#      rcvr_accessor :screen_name,  String
#      rcvr_accessor :follower_ids, Array, :of => Integer
#      # accumulate unique follower ids
#      def receive_follower_ids(arr)
#        @follower_ids = (@follower_ids||[]) + arr.map(&:to_i)
#        @follower_ids.uniq!
#      end
#    end
#
# The receiver pattern works naturally with inheritance:
#
#    class TweetWithUser < Tweet
#      rcvr_accessor :user, TwitterUser
#      after_receive do |hsh|
#        self.user_id = self.user.id if self.user
#      end
#    end
#    p TweetWithUser.receive(:id => 8675309, :created_at => "20101231010203", :user => { :id => 24601, :screen_name => 'bob', :follower_ids => [1, 8, 3, 4] })
#     => #<TweetWithUser @id=8675309, @created_at=2010-12-31 07:02:03 UTC, @user=#<TwitterUser @id=24601, @screen_name="bob", @follower_ids=[1, 8, 3, 4]>, @user_id=24601>
#
# TweetWithUser was able to add another receiver, applicable only to itself and its subclasses.
#
# The receive method works well with sparse data -- you can accumulate
# attributes without trampling formerly set values:
#
#    tw = Tweet.receive(:id => "7", :user_id => 9 )
#    p tw
#    # => #<Tweet @id=7, @user_id=9>
#
#    tw.receive!(:created_at => "20101231010203" )
#    p tw
#    # => #<Tweet @id=7, @user_id=9, @created_at=2010-12-31 07:02:03 UTC>
#
# Note the distinction between an explicit nil field and a missing field:
#
#    tw.receive!(:user_id => nil, :created_at => "20090506070809" )
#    p tw
#    # => #<Tweet @id=7, @user_id=nil, @created_at=2009-05-06 12:08:09 UTC>
#
# There are helpers for default and required attributes:
#
#    class Foo
#      include Receiver
#      rcvr_accessor :is_reqd,     String, :required => true
#      rcvr_accessor :also_reqd,   String, :required => true
#      rcvr_accessor :has_default, String, :default => 'hello'
#    end
#    foo_obj = Foo.receive(:is_reqd => "hi")
#    # => #<Foo:0x00000100bd9740 @is_reqd="hi" @has_default="hello">
#    foo_obj.missing_attrs
#    # => [:also_reqd]
#
module Receiver

  RECEIVER_BODIES           = {} unless defined?(RECEIVER_BODIES)
  RECEIVER_BODIES[Symbol]   = %q{ v.blank? ? nil : v.to_sym }
  RECEIVER_BODIES[Integer]  = %q{ v.blank? ? nil : v.to_i }
  RECEIVER_BODIES[Float]    = %q{ v.blank? ? nil : v.to_f }
  RECEIVER_BODIES[String]   = %q{ v.to_s }
  RECEIVER_BODIES[Time]     = %q{ v.nil?   ? nil : Time.parse(v.to_s).utc rescue nil }
  RECEIVER_BODIES[Date]     = %q{ v.nil?   ? nil : Date.parse(v.to_s)     rescue nil }
  RECEIVER_BODIES[Array]    = %q{ case when v.nil? then nil when v.blank? then [] else Array(v) end }
  RECEIVER_BODIES[Hash]     = %q{ case when v.nil? then nil when v.blank? then {} else v end }
  RECEIVER_BODIES[Boolean]  = %q{ case when v.nil? then nil when v.to_s.strip.blank? then false else v.to_s.strip != "false" end }
  RECEIVER_BODIES[NilClass] = %q{ raise ArgumentError, "This field must be nil, but {#{v}} was given" unless (v.nil?) ; nil }
  RECEIVER_BODIES[Object]   = %q{ v } # accept and love the object just as it is

  #
  # Give each base class a receive method
  #
  RECEIVER_BODIES.each do |k,b|
    if k.is_a?(Class)
      k.class_eval <<-STR, __FILE__, __LINE__ + 1
      def self.receive(v)
        #{b}
      end
      STR
    end
  end

  TYPE_ALIASES = {
    :null    => NilClass,
    :boolean => Boolean,
    :string  => String,  :bytes   => String,
    :symbol  => Symbol,
    :int     => Integer, :integer => Integer,  :long    => Integer,
    :time    => Time,    :date    => Date,
    :float   => Float,   :double  => Float,
    :hash    => Hash,    :map     => Hash,
    :array   => Array,
  } unless defined?(TYPE_ALIASES)

  #
  # modify object in place with new typecast values.
  #
  def receive! hsh={}
    raise ArgumentError, "Can't receive (it isn't hashlike): {#{hsh.inspect}}" unless hsh.respond_to?(:[]) && hsh.respond_to?(:has_key?)
    self.class.receiver_attr_names.each do |attr|
      if    hsh.has_key?(attr.to_sym) then val = hsh[attr.to_sym]
      elsif hsh.has_key?(attr.to_s)   then val = hsh[attr.to_s]
      else  next ; end
      _receive_attr attr, val
    end
    impose_defaults!(hsh)
    run_after_receivers(hsh)
    self
  end

  # true if the attr is a receiver variable and it has been set
  def attr_set?(attr)
    receiver_attrs.has_key?(attr) && self.instance_variable_defined?("@#{attr}")
  end

protected

  def unset!(attr)
    self.send(:remove_instance_variable, "@#{attr}") if self.instance_variable_defined?("@#{attr}")
  end

  def _receive_attr attr, val
    self.send("receive_#{attr}", val)
  end

  def impose_defaults!(hsh)
    self.class.receiver_defaults.each do |attr, val|
      next if attr_set?(attr)
      self.instance_variable_set "@#{attr}", val
    end
  end

  def run_after_receivers(hsh)
    self.class.after_receivers.each do |after_receiver|
      self.instance_exec(hsh, &after_receiver)
    end
  end

public

  module ClassMethods

    #
    # Returns a new instance with the given hash used to set all rcvrs.
    #
    # All args after the first are passed to the initializer.
    #
    # @param hsh [Hash] attr-value pairs to set on the newly created object
    # @param *args [Array] arguments to pass to the constructor
    # @return [Object] a new instance
    def receive *args
      hsh = args.extract_options!
      raise ArgumentError, "Can't receive (it isn't hashlike): {#{hsh.inspect}} -- the hsh should be the *last* arg" unless hsh.respond_to?(:[]) && hsh.respond_to?(:has_key?)
      obj = self.new(*args)
      obj.receive!(hsh)
    end

    #
    # define a receiver attribute.
    # automatically generates an attr_accessor on the class if none exists
    #
    # @option [Boolean] :required - Adds an error on validation if the attribute is never set
    # @option [Object]  :default  - After any receive! operation, attribute is set to this value unless attr_set? is true
    # @option [Class]   :of       - For collections (Array, Hash, etc), the type of the collection's items
    #
    def rcvr name, type, info={}
      name = name.to_sym
      type = type_to_klass(type)
      class_eval <<-STR, __FILE__, __LINE__ + 1
        def receive_#{name}(v)
          v = (#{receiver_body_for(type, info)}) ;
          self.instance_variable_set("@#{name}", v)
        end
      STR
      # careful here: don't modify parent's class_attribute in-place
      self.receiver_attrs = self.receiver_attrs.dup
      self.receiver_attr_names += [name] unless receiver_attr_names.include?(name)
      self.receiver_attrs[name] = info.merge({ :name => name, :type => type })
    end

    # make a block to run after each time  .receive! is invoked
    def after_receive &block
      self.after_receivers += [block]
    end

    # defines a receiver attribute, an attr_reader and an attr_writer
    # attr_reader is skipped if the getter method is already defined;
    # attr_writer is skipped if the setter method is already defined;
    def rcvr_accessor name, type, info={}
      attr_reader(name) unless method_defined?(name)
      attr_writer(name) unless method_defined?("#{name}=")
      rcvr name, type, info
    end
    # defines a receiver attribute and an attr_reader
    # attr_reader is skipped if the getter method is already defined.
    def rcvr_reader name, type, info={}
      attr_reader(name) unless method_defined?(name)
      rcvr name, type, info
    end
    # defines a receiver attribute and an attr_writer
    # attr_writer is skipped if the setter method is already defined.
    def rcvr_writer name, type, info={}
      attr_writer(name) unless method_defined?("#{name}=")
      rcvr name, type, info
    end

    #
    # Defines a receiver for attributes sent to receive! that are
    # * not defined as receivers
    # * attribute name does not start with '_'
    #
    # @example
    #     class Foo ; include Receiver
    #       rcvr_accessor  :bob, String
    #       rcvr_remaining :other_params
    #     end
    #     foo_obj = Foo.receive(:bob => 'hi, bob", :joe => 'hi, joe')
    #     # => <Foo @bob='hi, bob' @other_params={ :joe => 'hi, joe' }>
    def rcvr_remaining name, info={}
      rcvr_reader name, Hash, info
      after_receive do |hsh|
        remaining_vals_hsh = hsh.reject{|k,v| (receiver_attrs.include?(k)) || (k.to_s =~ /^_/) }
        self._receive_attr name, remaining_vals_hsh
      end
    end

    # a hash from attribute names to their default values if given
    def receiver_defaults
      defs = {}
      receiver_attrs.each do |name, info|
        defs[name] = info[:default] if info.has_key?(:default)
      end
      defs
    end

  protected
    def receiver_body_for type, info
      type = type_to_klass(type)
      # Note that Array and Hash only need (and only get) special treatment when
      # they have an :of => SomeType option.
      case
      when info[:of] && (type == Array)
        %Q{ v.nil? ? nil : v.map{|el| #{info[:of]}.receive(el) } }
      when info[:of] && (type == Hash)
        %Q{ v.nil? ? nil : v.inject({}){|h, (el,val)| h[el] = #{info[:of]}.receive(val); h } }
      when Receiver::RECEIVER_BODIES.include?(type)
        Receiver::RECEIVER_BODIES[type]
      when type.is_a?(Class)
        %Q{v.blank? ? nil : #{type}.receive(v) }
      # when (type.is_a?(Symbol) && type.to_s =~ /^[A-Z]/)
      #   # a hack so you can use a class not defined yet
      #   %Q{v.blank? ? nil : #{type}.receive(v) }
      else
        raise("Can't receive #{type} #{info}")
      end
    end

    def type_to_klass(type)
      case
      when type.is_a?(Class)                             then return type
      when TYPE_ALIASES.has_key?(type)                   then TYPE_ALIASES[type]
      # when (type.is_a?(Symbol) && type.to_s =~ /^[A-Z]/) then type.to_s.constantize
      else raise ArgumentError, "Can\'t handle type #{type}: is it a Class or one of the TYPE_ALIASES?"
      end
    end
  end

  # set up receiver attributes, and bring in methods from the ClassMethods module at class-level
  def self.included base
    base.class_eval do
      class_attribute :receiver_attrs
      class_attribute :receiver_attr_names
      class_attribute :after_receivers
      self.receiver_attrs      = {} # info about the attr
      self.receiver_attr_names = [] # ordered set of attr names
      self.after_receivers     = [] # blocks to execute following receive!
      extend ClassMethods
    end
  end
end
