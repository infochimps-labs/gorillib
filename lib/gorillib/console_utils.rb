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
    pref         = "%-3d %-14s %-21s" % [@call_count, __id__, self.to_s]
    @call_count += 1
    $stderr.puts   "%s %-10s <-  %-30s %s -- %s" % [pref, meth, args.inspect, block, ::Kernel.caller.first]
    ret = @obj.__send__(meth, *args, &block)
    $stderr.puts   "%s %-10s  -> %s"             % [pref, meth, ret.inspect] if @show_ret
    ret
  end
end


module ModA ; def from_mod_a() "ModA#from_mod_a on #{self}" ; end ; def override_me ; "ModA#override_me on #{self}" ; end ; end
module ModB ; def from_mod_b() "ModB#from_mod_b on #{self}" ; end ; def some_method ; "ModB#some_method on #{self}" ; end ; end
module ModC ; def from_mod_c() "ModC#from_mod_c on #{self}" ; end ; end
class  Cls1
  include ModA
  def from_cls_1() "Cls1#from_cls_1 on #{self}" ; end
end
class  Cls2 < Cls1
  extend  ModB
  include ModC
  def override_me ; "Cls2#override_me on #{self}" ; end
  def from_cls_2  ; "Cls2#from_cls_2 on #{self}"  ; end
end
class Cls3
  def override_me ; "Cls3#override_me on #{self}" ; end
  def some_method ; "Cls3#some_method on #{self}" ; end
end

class Module

  #
  # Lists the differences in methods between two modules/classes
  #
  def compare_methods(that=Object, show_common=false)
    result = Hash.new{|h,k| h[k] = Hash.new{|hh,hk| hh[hk] = [] } }

    inst_ancestors_both  = ancestors                 & that.ancestors
    klass_ancestors_both = singleton_class.ancestors & that.singleton_class.ancestors

    inst_meths  = (self.instance_methods | that.instance_methods)
    klass_meths = (self.methods          | that.methods)

    [ [:both, inst_ancestors_both,                     klass_ancestors_both],
      [self,  (self.ancestors - inst_ancestors_both), (self.singleton_class.ancestors - klass_ancestors_both)],
      [that,  (that.ancestors - inst_ancestors_both), (that.singleton_class.ancestors - klass_ancestors_both)],
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
    result
  end

end
