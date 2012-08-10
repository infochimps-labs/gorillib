#!/usr/bin/env ruby

require 'benchmark'
require 'benchmark/ips'  # https://github.com/evanphx/benchmark-ips and benchmark_suite

require 'gorillib'
require 'gorillib/model'
# load(File.expand_path("../gorillib/lib/gorillib/model/factories.rb"))

module Gorillib::Factory

  NUMERIC_FACTORIES = {
    # :integer      => IntegerFactory.new(),                                 # uses Integer() -- strict (will not convert a float-y string)
    # :float        => FloatFactory.new(),                                   # uses Float() -- strict
    :gr_int       => GraciousIntegerFactory.new(),
    :gr_intfo     => FooFactory.new(),
    :gr_intsg     => IntegerFactory.new(),

    :gr_intst     => IntegerFactory.new(convert: ->(obj){
        if String === obj       then
          obj = obj.to_s.tr(FLT_CRUFT_CHARS, '') ;
          obj = Float(obj) if FLT_NOT_INT_RE === obj ;
        end
        Integer(obj) } ),
    :gr_int2       => GraciousIntegerFactory.new(),
    :gr_ints2     => IntegerFactory.new(convert: ->(obj){
        if ::String === obj       then
          obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
          obj = ::Kernel::Float(obj) if ::Gorillib::Factory::FLT_NOT_INT_RE === obj ;
        end
        ::Kernel::Integer(obj) } ),
    # :gr_intsm     => GraciousIntegerFactory.new(),

    # #:gr_flt     => GraciousFloatFactory.new(),

    #
    # :intfun     => IntegerFactory.new(convert: ->(obj){ Integer(obj) }), # no regex involved
    # :to_i       => IntegerFactory.new(convert: ->(obj){ obj.to_i }),     # should be same-ish as gracious_int
    # :floatfun   => FloatFactory.new(convert: ->(obj){ Float(obj) }),     # should be same-ish as float
    # :to_f       => FloatFactory.new(convert: ->(obj){ obj.to_f }),       # should be same-ish as gracious_float

    # # # Checking with a regex is about 25% faster in the case nothing is needed (it's just a plain old string), 25% slower in the case something is.
    # # # I assume you want this because the non-plain cases are important, so we go with the one that's fair to everyone.
    # :gr_intrs     => IntegerFactory.new(convert: ->(obj){ if INT_CRUFT_RE === obj then obj = Float(obj.to_s.tr(FLT_CRUFT_CHARS,'')) ; end ; Integer(obj) } ),
    # # # these are bad. gsub is slower than tr, the to_s is harmless; the constant is harmless possibly beneficial
    # :gr_intrt   => IntegerFactory.new(convert: ->(obj){ if INT_CRUFT_RE === obj then obj = Float(obj.tr(',fFlL',''))         ; end ; Integer(obj) } ),
    # :gr_intra   => IntegerFactory.new(convert: ->(obj){ if INT_CRUFT_RE === obj then obj = Float(obj.gsub(FLT_CRUFT_RE,''))  ; end ; Integer(obj) } ),
    # :gr_intsa   => IntegerFactory.new(convert: ->(obj){ if String       === obj then obj = Float(obj.gsub(FLT_CRUFT_RE, '')) ; end ; Integer(obj) } ),
    # # # rolling back to pig-only doesn't do as much as you'd think
    # :gr_intrx     => IntegerFactory.new(convert: ->(obj){ if PIG_FLT_RE === obj then obj = $1                                     ; end ; Integer(obj) } ),
    # :gr_pig       => IntegerFactory.new(convert: ->(obj){
    #     if PIG_INT_RE     === obj then obj = $1 ; end ;
    #     Integer(obj) } ),
    # :gr_intr3     => IntegerFactory.new(convert: ->(obj){
    #     if PIG_FLT_RE     === obj then obj = $1 ; end ;
    #     obj = obj.to_s.tr(',', '') if /,/ === obj ;
    #     if FLT_NOT_INT_RE === obj then obj = Float(obj) ; end ;
    #     Integer(obj) } ),
  }
  # NUMERIC_FACTORIES[:gr_intsm].define_singleton_method(:convert, &NUMERIC_FACTORIES[:gr_intsm].method(:convert))
  NUMERIC_FACTORIES[:gr_intsg].define_singleton_method(:convert, &FOO_BLK)

  NUMERIC_OBJECTS = [
    "1_234.5e4f",
    "1_234_567.1234e+40",
    "1_234",
    "123456789_123456789_123456789_123456789_123456789",
    "1234L",
    "1,234,567",
    "1_234.5e4",
    # 1234, 1234.5,
    # Time.now,
    # "0x11", '0x1.999999999999ap4'
  ]

  class FactoryBencher
    include Gorillib::Model
    field :step_duration, Integer, position: 0, default: 1.0, doc: "Target duration of each benchmarking step"
    field :warm_duration, Integer, position: 0, default: 0.1, doc: "Target duration of warmup step"

    def benchmark_factory(factories)
      ips do |bench|
        NUMERIC_OBJECTS.each do |obj|
          puts "=== Converting +%-20s+: %s" % [
            obj.inspect, factories.map{|fn, fact| "#{fn}: #{fact.receive(obj) rescue '(err)'}" }.join(" | ")]
        end
          NUMERIC_OBJECTS.each do |obj|
          factories.each do |factory_name, factory|
            GC.start
            msg = "%-15s%10s" % [obj.inspect[0..14], factory_name]
            bench.report(msg){ factory.receive(obj) }
            # bench.report('to_i baseline' ){ obj.to_i }
            # bench.report('to_f baseline' ){ obj.to_f }
          end
        end
      end
    end

    def benchmark_baseline
      objs = NUMERIC_OBJECTS
      ips do |bench|
        objs.each{|obj| bench.report("#{obj.inspect[0..9]} #to_i"     ){ obj.to_i            } }
        objs.each{|obj| bench.report("#{obj.inspect[0..9]} #to_f"     ){ obj.to_f            } }
        objs.each{|obj| bench.report("#{obj.inspect[0..9]} Integer()" ){ Integer(obj)        } }
        objs.each{|obj| bench.report("#{obj.inspect[0..9]} Float())"  ){ Float(obj)          } }
        objs.each{|obj| bench.report("#{obj.inspect[0..9]} Int(Fl())" ){ Integer(Float(obj)) } }
      end
    end

    def ips(&block)
      Benchmark.ips(step_duration, warm_duration, &block)
    end
  end

  bencher = FactoryBencher.new
  bencher.benchmark_factory(NUMERIC_FACTORIES)
  # NUMERIC_OBJECTS.each do |obj|
  #   bencher.benchmark_factory(obj, NUMERIC_FACTORIES)
  # end
  # bencher.benchmark_baseline
end
