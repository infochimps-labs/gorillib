# require File.dirname(__FILE__)+'/../spec_helper'
# require GORILLIB_ROOT_DIR('spec/support/hashlike_fuzzing_helper')
# require 'gorillib/hashlike'
# require 'gorillib/hashlike/hashlike_via_accessors'
# 
# class UsingHashlikeViaAccessors
#   include Gorillib::Hashlike::HashlikeViaAccessors
#   include Gorillib::Hashlike
# 
#   attr_accessor :a, :b, :c, :nil_val, :false_val, :z
# 
#   # We override these just to be able to compare exceptions.
#   def to_s()
#     '{' + [:a, :b, :c, :nil_val, :false_val, :z].map{|k| [k, self[k]].join('=>') }.join(',') + '}'
#   end
#   def ==(other_hash)
#     (length == other_hash.length) && all?{|k,v| v == other_hash[k] }
#   end
# end
# 
# 
# describe Gorillib::Hashlike::HashlikeViaAccessors do
#   include HashlikeFuzzingHelper
# 
# 
#   before do
#     @total = 0
#     hsh = { :a  => 3,  :b  => 4, :c => nil, :nil_val => nil, :false_val => false, :z => nil }
#     @hsh_symk = hsh.dup
#     @hsh_strk = {} ; hsh.each{|k,v| @hsh_strk[k.to_s] = v }
#     @hsh_wia   = hsh.with_indifferent_access
#     @hshlike  = InternalHash.new.merge(hsh)
# 
#     p [@hshlike]
#   end
# 
# end
