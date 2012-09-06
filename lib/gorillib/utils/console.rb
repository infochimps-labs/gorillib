#
# An inspecting delegator.
#
# Create a trap passing in any object of your choice.
#
# Any time a method is called on the trap, it prints the method name, all its
# args, and the direct caller.
#
# @example Did you know how basic operators work? Now you do!
#
#    trapped_int = ItsATrap.new(3)
#
#    trapped_int - 55
#    [:-, [55], nil, "..."]
#    => -52
#
#    55 - trapped_int
#    [:coerce, [55], nil, "..."]
#    => 52
#
#    - trapped_int
#    [:-@, [], nil, "..."]
#    => -3
#
class ItsATrap < BasicObject
  def initialize(obj=::Object.new, show_ret=false)
    @obj        = obj
    @call_count = 0
    @show_ret   = show_ret
  end

  # We implement to_s and inspect, because otherwise it's annoyingly noisy. :pretty_inspect makes pry happy.

  def inspect() "~#{@obj.inspect}~" ; end
  def to_s()    @obj.to_s        ; end
  alias_method :pretty_inspect, :inspect
  def methods() @obj.methods ; end

  # @return the proxied object
  def __obj__ ; @obj ; end

  # These are defined on BasicObject, delegate them along with the rest
  #   BasicObject.instance_methods
  #   => [:==, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]

  def ==(    *args, &block)        ; __describe_and_send__(:==,     *args, &block) ; end
  def equal?(*args, &block)        ; __describe_and_send__(:equal?, *args, &block) ; end
  def !@(    *args, &block)        ; __describe_and_send__(:!,      *args, &block) ; end
  def !=(    *args, &block)        ; __describe_and_send__(:!=,     *args, &block) ; end
  def instance_eval(*args, &block) ; __describe_and_send__(:instance_eval, *args, &block) ; end
  def instance_exec(*args, &block) ; __describe_and_send__(:instance_exec, *args, &block) ; end

private

  #
  # Any time a method is called on the trap, it prints the method name, all its
  # args, and the direct caller.
  #
  def method_missing(meth, *args, &block)
    __describe_and_send__(meth, *args, &block)
  end

  def __describe_and_send__(meth, *args, &block)
    pref         = "%-3d %-14s %-15s" % [@call_count, @obj.__id__, self.to_s[0..14]]
    @call_count += 1
    $stderr.puts   "%s %-15s <-  %-30s %s -- %s" % [pref, meth.to_s[0..14], args.map(&:inspect).join(','), block, ::Kernel.caller.first]
    ret = @obj.__send__(meth, *args, &block)
    $stderr.puts   "%s %-15s  -> %s"             % [pref, meth.to_s[0..14], ret.inspect] if @show_ret
    ret
  end
end

class Module

  #
  # Lists the differences in methods between two modules/classes
  #
  # Breaks them down by providing module, and shows class and instance methods.
  # @param other [Module] other class or module to compare with
  # @param show_common [true,false] true to show methods they have in common; false by default
  #
  # @example Range has several extra instance methods; the Foo class and its instances have methods via the Happy module
  #   module Happy ; def hello() 3 ; end ; end
  #   class  Foo   ; include Enumerable ; include Happy ; extend Happy ; end
  #   { "Foo#"   => { Happy => [:hello] },
  #     "Foo."   => { Happy => [:hello] },
  #     "Range#" => { Range => [:each, :step, :begin, :end, :last, :exclude_end?, :cover?]} }
  #
  def compare_methods(other=Object, show_common=false)
    result = Hash.new{|h,k| h[k] = Hash.new{|hh,hk| hh[hk] = [] } }

    inst_ancestors_both  = ancestors                 & other.ancestors
    klass_ancestors_both = singleton_class.ancestors & other.singleton_class.ancestors

    inst_meths  = (self.instance_methods | other.instance_methods)
    klass_meths = (self.methods          | other.methods)

    [ [:both, inst_ancestors_both,                     klass_ancestors_both],
      [self,   (self.ancestors  - inst_ancestors_both), (self.singleton_class.ancestors  - klass_ancestors_both)],
      [other,  (other.ancestors - inst_ancestors_both), (other.singleton_class.ancestors - klass_ancestors_both)],
    ].each do |mod, inst_anc, klass_anc|
      inst_anc.reverse.each do |ancestor|
        result["#{mod}#"][ancestor] = inst_meths & ancestor.instance_methods
        inst_meths -= ancestor.instance_methods
      end
      klass_anc.reverse.each do |ancestor|
        result["#{mod}."][ancestor] = klass_meths & ancestor.instance_methods
        klass_meths -= ancestor.instance_methods
      end
    end
    unless show_common then result.delete("both#") ; result.delete("both.") ; end
    result.each{|type,hsh|    hsh.reject!{|k,v| v.empty? } }
    result.reject!{|type,hsh| hsh.empty? }
    result
  end

end
