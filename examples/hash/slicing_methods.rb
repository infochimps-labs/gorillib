#!/usr/bin/env ruby

require 'formatador'
require 'active_support/core_ext/hash/slice.rb'
load File.expand_path('../../lib/gorillib/hashlike/slice.rb', File.dirname(__FILE__))
load File.expand_path('../../lib/gorillib/hash/mash.rb',      File.dirname(__FILE__))

# +-----------+-------+---------+-------------+---------------------------+--------------------+
# | method    | kind  | altered | returns     | result                    | receiver           |
# +-----------+-------+---------+-------------+---------------------------+--------------------+
# | select    | block | -       | copy        | {:a=>"A", :c=>"A"}        | (unchanged)        |
# | only      | list  | -       | copy        | {:a=>"A", :c=>"A"}        | (unchanged)        |
# | slice     | list  | -       | copy        | {:a=>"A", :c=>"A"}        | (unchanged)        |
# | reject    | block | -       | copy        | {:b=>"not A"}             | (unchanged)        |
# | except    | list  | -       | copy        | {:b=>"not A"}             | (unchanged)        |
# | select!   | block | yes     | self or nil | {:a=>"A", :c=>"A"} or nil | {:a=>"A", :c=>"A"} |
# | keep_if   | block | yes     | self        | {:a=>"A", :c=>"A"}        | {:a=>"A", :c=>"A"} |
# | only!     | list  | yes     | self        | {:a=>"A", :c=>"A"}        | {:a=>"A", :c=>"A"} |
# | slice!    | list  | yes     | copy        | {:b=>"not A"}             | {:a=>"A", :c=>"A"} |
# | reject!   | block | yes     | self or nil | {:b=>"not A"} or nil      | {:b=>"not A"}      |
# | delete_if | block | yes     | self        | {:b=>"not A"}             | {:b=>"not A"}      |
# | except!   | list  | yes     | self        | {:b=>"not A"}             | {:b=>"not A"}      |
# | extract!  | list  | yes     | copy        | {:a=>"A", :c=>"A"}        | {:b=>"not A"}      |
# +-----------+-------+---------+-------------+---------------------------+--------------------+

SLICING_METHODS = [
  :select,              :only,    :slice,
  :reject,              :except,
  :select!, :keep_if,   :only!,   :slice!,
  :reject!, :delete_if, :except!, :extract!, ]


class Hashish < Hash
  include Gorillib::Hashlike::Slice
  include Gorillib::Hashlike::ExceptOnly
end
class Mashish < Mash
  include Gorillib::Hashlike::ExceptOnly
end

EXAMPLE_HASH      = { a: 'A', b: 'not A', c: 'A' }.freeze
EXAMPLE_MASH      = Mash   .new.merge!(EXAMPLE_HASH).freeze
EXAMPLE_HASHISH   = Hashish.new.merge!(EXAMPLE_HASH).freeze
EXAMPLE_MASHISH   = Mashish.new.merge!(EXAMPLE_HASH).freeze

# The given set of keys, 'A' -- either as list or block
GIVEN_KEYS   = [:c, :a]
GIVEN_BLK    = ->(key,val){ val == 'A' }

KLASS_COLORS = {Hashish => 'green', Mash => 'blue', Hash => 'red'}

def colorize(item, choices)
  color = choices[item] or return item
  "[#{color}]#{item}[/]"
end

def slicing_method_report(obj, meth)
  return :split if meth == :split
  return({ method: meth, result: '(unimplemented)' }) unless obj.respond_to?(meth)
  hsh        = obj.dup
  kind       = (hsh.method(meth).arity == 0) ? :block : :list
  result     = (kind == :block) ? hsh.send(meth, &GIVEN_BLK) : hsh.send(meth, *GIVEN_KEYS)
  #
  altered    = (hsh == obj)
  result_str = result.to_s
  returns    = result.equal?(hsh) ? 'self' : 'copy'
  if [:select!, :reject!].include?(meth)
    result_str << " or nil"; returns << " or nil"
  end
  ret_class  = colorize(result.class, KLASS_COLORS)
  obj_class  = colorize(obj.class,    KLASS_COLORS)
  src_loc, _ = hsh.method(meth).source_location
  provider   = case src_loc when /gorillib\/hashlike\/slice/ then 'gorillib' when /activesupp/ then 'activesupp' when nil then 'internal' else 'other' ; end

  { method: meth,     kind: kind,         altered: (altered ? '-' : 'yes'),
    returns: returns, result: result_str, receiver: (altered ? '(unchanged)' : hsh),
    provider: provider, obj_class: obj_class, ret_class: ret_class }
end

def display_results_table
  info = SLICING_METHODS.flat_map do |meth|
    [EXAMPLE_HASH, EXAMPLE_MASH, EXAMPLE_HASHISH, EXAMPLE_MASHISH].flat_map do |obj|
      slicing_method_report(obj, meth)
    end + [:split]
  end
  Formatador.display_compact_table(info,
    [:method, :kind, :altered, :returns, :result, :receiver, :provider, :obj_class, :ret_class] )
end

puts
puts "Results for hash #{EXAMPLE_HASH.inspect}, of hash.meth(:a, :c) or"
puts "  hash.meth{|key, val| val == 'A'} as appropriate."
puts "  Note: select! and reject! act resp. like keep_if and delete_if"
puts "  but return nil if the contents are unchanged."
puts

display_results_table

# display_results_table(EXAMPLE_HASHISH)
#
# display_results_table(EXAMPLE_MASH)
