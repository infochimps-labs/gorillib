#!/usr/bin/env ruby

require 'benchmark'
require 'benchmark/ips'  # https://github.com/evanphx/benchmark-ips and benchmark_suite

require 'gorillib'
require 'gorillib/model'
# load(File.expand_path("../gorillib/lib/gorillib/model/factories.rb"))

module Gorillib::Factory

  NUMERIC_FACTORIES = {
    :int          => IntegerFactory.new(),     # uses Integer() -- strict (will not convert a float-y string)
    :flt          => FloatFactory.new(),       # uses Float() -- strict
    :gr_int       => GraciousIntegerFactory.new(),
    :gr_float     => GraciousFloatFactory.new(),

    # indiscriminately Integer or to_i anything you see
    :gri_to_i     => GraciousIntegerFactory.new(convert: ->(obj){ obj.to_i     }),
    :gri_dirct    => GraciousIntegerFactory.new(convert: ->(obj){ Integer(obj) }),

    # same as basic GraciousIntegerFactory, but strangely defining a block here
    # is *way* faster, so for fair conversion to :gr_int_direct and :gr_int_to_i
    # I've duplicated it here
    :gri_blk      => IntegerFactory.new(convert: ->(obj){
        if String === obj       then
          obj = obj.to_s.tr(FLT_CRUFT_CHARS, '') ;
          obj = Float(obj) if FLT_NOT_INT_RE === obj ;
        end
        Integer(obj) } ),
  }

  NUMERIC_OBJECTS = [
    "1_234.5e4f",
    "1_234_567.1234e+40",
    "1_234",
    "123456789_123456789_123456789_123456789_123456789",
    "1234L",
    "1,234,567",
    "1_234.5e4",
    1234, 1234.5,
    Time.now,
    "0x11", '0x1.999999999999ap4'
  ]

  class FactoryBencher
    include Gorillib::Model
    field :step_duration, Integer, position: 0, default: 2.0, doc: "Target duration of each benchmarking step"
    field :warm_duration, Integer, position: 0, default: 0.1, doc: "Target duration of warmup step"

    def benchmark_factory(factories)
      NUMERIC_OBJECTS.each do |obj|
        puts "=== Converting +%-20s+: %s" % [
          obj.inspect, factories.map{|fn, fact| "#{fn}: #{fact.receive(obj) rescue '(err)'}" }.join(" | ")]
      end
      NUMERIC_OBJECTS.each do |obj|
        ips do |bench|
          factories.each do |factory_name, factory|
            msg = "%-15s%10s" % [obj.inspect[0..14], factory_name]
            bench.report(msg){ factory.receive(obj) }
          end
          bench.report('to_i baseline' ){ obj.to_i }
          bench.report('to_f baseline' ){ obj.to_f }
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
  bencher.benchmark_baseline
end
