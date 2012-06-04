require 'gorillib/metaprogramming/delegation'

class ::Long      < ::Integer ; end
class ::Double    < ::Float   ; end
class ::Binary    < ::String  ; end

class ::Guid      < ::String  ; end
class ::IpAddress < ::String  ; end
class ::Hostname  < ::String  ; end

# class ::Boolean < ::Object
#   attr_accessor :val
#   def initialize(val=nil)
#     self.val = val
#   end
#
#   delegate :!,  :to_s, :blank?, :frozen?, :nil?, :present?, :to => :val
#   delegate :!=, :&, :<=>, :=~, :^, :|, :to => :val
#
#   def inspect()
#     "<Boolean #{val.inspect}>"
#   end
#   def try_dup()
#     ::Boolean.new(val)
#   end
#
#   def self.true  ; self.new(true)  ; end
#   def self.false ; self.new(false) ; end
#
#   def is_a?(klass)        val.is_a?(klass)        || super ; end
#   def kind_of?(klass)     val.kind_of?(klass)     || super ; end
#   def instance_of?(klass) val.instance_of?(klass) || super ; end
#
#   def     !=(other_val) other_val = other_val.val if other_val.is_a?(::Boolean) ; (val     != other_val) ; end
#   def     ==(other_val) other_val = other_val.val if other_val.is_a?(::Boolean) ; (val     == other_val) ; end
#   def    ===(other_val) other_val = other_val.val if other_val.is_a?(::Boolean) ; (val    === other_val) ; end
#   def    <=>(other_val) other_val = other_val.val if other_val.is_a?(::Boolean) ; (val    <=> other_val) ; end
#   def   eql?(other_val) other_val = other_val.val if other_val.is_a?(::Boolean) ; (val.eql?   other_val) ; end
#   def equal?(other_val) other_val = other_val.val if other_val.is_a?(::Boolean) ; (val.equal? other_val) ; end
#
# end

# Datamapper also defines:
#
#  Apikey BCryptHash Decimal URI UUID Slug CommaSeparatedList Csv IpAddress Json Yaml Enum Flag Discriminator
#
# maybe someday we will too...
