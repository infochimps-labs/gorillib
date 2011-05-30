#
# to isolate the hashlike contract, implements the basic 4 methods it expects
# ([], []=, delete, keys) by delegating to an actual hash.
#
class InternalHash < Object
  include Gorillib::Hashlike
  def initialize
    @myhsh = {}
  end
  def [](*args,&blk)     @myhsh.[](*args, &blk)     ; end
  def []=(*args,&blk)    @myhsh.[]=(*args, &blk)    ; end
  def delete(*args,&blk) @myhsh.delete(*args, &blk) ; end
  def keys(*args,&blk)   @myhsh.keys(*args, &blk)   ; end
end
