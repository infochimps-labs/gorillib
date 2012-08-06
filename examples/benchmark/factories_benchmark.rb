#!/usr/bin/env ruby

require 'benchmark'
require 'benchmark/ips'  # https://github.com/evanphx/benchmark-ips and benchmark_suite

require 'gorillib'
require 'gorillib/model'
load(File.expand_path("../gorillib/lib/gorillib/model/factories.rb"))

module Gorillib::Factory

  INTEGER_FACTORIES = {
    :integer      => IntegerFactory.new(),                                 # mostly like Integer() but traps floats
    :intfun       => IntegerFactory.new(convert: ->(obj){ Integer(obj) }), # no regex involved
    :grac_int     => GraciousIntegerFactory.new(),                         # uses #to_i, so mangles floats and hex,  and other weirdness
    # :to_i       => IntegerFactory.new(convert: ->(obj){ obj.to_i }),     # should be same-ish as gracious_int
  }

  FLOAT_FACTORIES = {
    :float        => FloatFactory.new(),                                   # uses Float()
    # :floatfun   => FloatFactory.new(convert: ->(obj){ Float(obj) }),     # should be same-ish as float
    :grac_float   => GraciousFloatFactory.new(),                           # uses #to_f, so mangles hex and other weirdness
    # :to_f       => FloatFactory.new(convert: ->(obj){ obj.to_f }),       # should be same-ish as gracious_float
  }

  NUMERIC_OBJECTS = [1234, 1234.5, "1_234", "1_234.5e4", Time.now, "1234L", "1234.5f", "0x11", '0x1.999999999999ap4']

  class FactoryBencher
    include Gorillib::Model
    field :step_duration, Integer, position: 0, default: 1.0, doc: "Target duration of each benchmarking step"

    def benchmark_factory(obj, factories)
      puts "\n=== Converting +%s+" % [obj.inspect]
      puts "       " + factories.map{|fn, fact| "#{fn}: #{fact.receive(obj) rescue '(err)'}" }.join(" | ")
      ips do |bench|
        factories.each do |factory_name, factory|
          bench.report("#{factory_name} factory"){ factory.receive(obj) }
        end
        bench.report('to_i baseline' ){ obj.to_i }
        # bench.report('to_f baseline' ){ obj.to_f }
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
      Benchmark.ips(step_duration, &block)
    end
  end

  bencher = FactoryBencher.new
  NUMERIC_OBJECTS.each do |obj|
    bencher.benchmark_factory(obj, INTEGER_FACTORIES)
    bencher.benchmark_factory(obj, FLOAT_FACTORIES)
  end
  bencher.benchmark_baseline
end
