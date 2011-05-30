#
# A minimal implementation of a Hashlike for testing
#
# Delegates the basic 4 methods Hashlike expects ([], []=, delete, keys) to an
# actual hash.
#
class InternalHash < Object

  include Gorillib::Hashlike

  attr_reader :myhsh
  def initialize
    @myhsh = {}
  end
  def [](*args,&blk)     @myhsh.[](*args, &blk)     ; end
  def []=(*args,&blk)    @myhsh.[]=(*args, &blk)    ; end
  def delete(*args,&blk) @myhsh.delete(*args, &blk) ; end
  def keys(*args,&blk)   @myhsh.keys(*args, &blk)   ; end

  def dup
    d = super
    d.instance_variable_set("@myhsh", @myhsh.dup)
    d
  end

  def hash_eql?(other_hsh)
    other_hsh = other_hsh.myhsh if other_hsh.is_a?(self.class)
    @myhsh == other_hsh
  end
end
