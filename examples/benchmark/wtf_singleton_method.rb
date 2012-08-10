#!/usr/bin/env ruby

require 'benchmark'
require 'benchmark/ips'  # https://github.com/evanphx/benchmark-ips and benchmark_suite

module Gorillib
  module Factory
    FLT_CRUFT_CHARS  = ',fFlL'
    FLT_NOT_INT_RE   = /[\.eE]/o

    class IntegerFactory
      def receive(obj)
        raise "override this"
      end
    end

    class GraciousIntegerFactory < IntegerFactory
      def receive(obj)
        if ::String === obj       then
          obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
          obj = ::Kernel::Float(obj) if obj.include?('.') || obj.include?('e') || obj.include?('E')
        end
        ::Kernel::Integer(obj)
      end
    end

    class StTrInc < IntegerFactory
      def receive(obj)
        if ::String === obj       then
          obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
          obj = ::Kernel::Float(obj) if obj.include?('.') || obj.include?('e') || obj.include?('E')
        end
        ::Kernel::Integer(obj)
      end
    end

    class StTrRe < IntegerFactory
      def receive(obj)
        if ::String === obj       then
          obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
          obj = ::Kernel::Float(obj) if ::Gorillib::Factory::FLT_NOT_INT_RE === obj ;
        end
        ::Kernel::Integer(obj)
      end
    end
    
    CONVERT_BLOCK = ->(obj){
      if ::String === obj       then
        obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
        obj = ::Kernel::Float(obj) if ::Gorillib::Factory::FLT_NOT_INT_RE === obj ;
      end
      ::Kernel::Integer(obj)
    }

    TESTOR = ->(obj){ ::Gorillib::Factory::FLT_NOT_INT_RE === obj }

    class TestorFactory < IntegerFactory
      def receive(obj)
        if ::String === obj       then
          obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
          obj = ::Kernel::Float(obj) if ::Gorillib::Factory::TESTOR.call(obj) ;
        end
        ::Kernel::Integer(obj)
      end
    end
    TESTOR_BLOCK = ->(obj) do
        if ::String === obj       then
          obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
          obj = ::Kernel::Float(obj) if ::Gorillib::Factory::TESTOR.call(obj) ;
        end
        ::Kernel::Integer(obj)
    end

    class OnlyreFactory < IntegerFactory
      def receive(obj)       ::Gorillib::Factory::FLT_NOT_INT_RE === obj ; end
    end
    ONLY_RE_BLOCK = ->(obj){ ::Gorillib::Factory::FLT_NOT_INT_RE === obj }

    class OnlyttFactory < IntegerFactory
      def receive(obj)       ::Gorillib::Factory::TESTOR.call(obj) ; end
    end
    ONLY_TT_BLOCK = ->(obj){ ::Gorillib::Factory::TESTOR.call(obj) ; }

    TT_1 = ->(obj){  /[\.eE]/ =~ obj }
    TT_2 = ->(obj){  /[\.eE]/o =~ obj }
    TT_3 = ->(obj){  ::Gorillib::Factory::FLT_NOT_INT_RE =~ obj }
    TT_4 = ->(obj){  ::Gorillib::Factory::FLT_NOT_INT_RE === obj }
    TT_5 = ->(obj){  obj.include?('.') }
    TT_6 = ->(obj){  obj.include?('.') || obj.include?('e') || obj.include?('E') }
    
    class Factory1 < IntegerFactory ; def receive(obj)     /[\.eE]/  =~ obj  ; end ; end
    class Factory2 < IntegerFactory ; def receive(obj) !! (/[\.eE]/ =~ obj)  ; end ; end
    class Factory3 < IntegerFactory ; def receive(obj)  ::Gorillib::Factory::FLT_NOT_INT_RE =~  obj ; end ; end
    class Factory4 < IntegerFactory ; def receive(obj)  ::Gorillib::Factory::FLT_NOT_INT_RE === obj ; end ; end
    class Factory5 < IntegerFactory ; def receive(obj)  obj.include?('.')                                           end ; end
    class Factory6 < IntegerFactory ; def receive(obj)  obj.include?('.') || obj.include?('e') || obj.include?('E') end ; end
    # class Factory2 < IntegerFactory ; def receive(obj)  /[\.eE]/o =~ obj  ; end ; end

    class Caller1 < IntegerFactory ; def receive(obj)  TT_1.call(obj) ; end ; end
    class Caller2 < IntegerFactory ; def receive(obj)  TT_2.call(obj) ; end ; end
    class Caller3 < IntegerFactory ; def receive(obj)  TT_3.call(obj) ; end ; end
    class Caller4 < IntegerFactory ; def receive(obj)  TT_4.call(obj) ; end ; end
    class Caller5 < IntegerFactory ; def receive(obj)  TT_5.call(obj) ; end ; end
    class Caller6 < IntegerFactory ; def receive(obj)  TT_6.call(obj) ; end ; end
    
    NUMERIC_FACTORIES = {
      # :tt             => TestorFactory.new(),
      # :tt_blk         => TestorFactory.new(),
      # :tt_o           => Object.new(),
      # #
      :gr               => GraciousIntegerFactory.new(),
      :st_tr_inc        => StTrInc.new(),
      :st_tr_re         => StTrRe.new(),
      # :gr_blk         => GraciousIntegerFactory.new(),
      # :gr_o           => Object.new(),
      #
      :f1              => Factory1.new,
      :f2              => Factory2.new,
      :f3              => Factory3.new,
      :f4              => Factory4.new,
      :f5              => Factory5.new,
      :f6              => Factory6.new,
      #
      :c1              => Caller1.new,
      :c2              => Caller2.new,
      :c3              => Caller3.new,
      :c4              => Caller4.new,
      :c5              => Caller5.new,
      :c6              => Caller6.new,

      #
      #
      # :ot             => OnlyttFactory.new(),
      # :ot_blk         => OnlyttFactory.new(),
      # :ot_o           => Object.new(),
      # #
      # :or             => OnlyreFactory.new(),
      # :or_blk         => OnlyreFactory.new(),
      # :or_o           => Object.new(),
    }

    # NUMERIC_FACTORIES[:gr_blk ].define_singleton_method(:receive, &CONVERT_BLOCK)
    # NUMERIC_FACTORIES[:gr_o   ].define_singleton_method(:receive, &CONVERT_BLOCK)
    # NUMERIC_FACTORIES[:tt_blk ].define_singleton_method(:receive, &TESTOR_BLOCK)
    # NUMERIC_FACTORIES[:tt_o   ].define_singleton_method(:receive, &TESTOR_BLOCK)

    # NUMERIC_FACTORIES[:or_blk ].define_singleton_method(:receive, &ONLY_RE_BLOCK)
    # NUMERIC_FACTORIES[:or_o   ].define_singleton_method(:receive, &ONLY_RE_BLOCK)
    # NUMERIC_FACTORIES[:ot_blk ].define_singleton_method(:receive, &ONLY_TT_BLOCK)
    # NUMERIC_FACTORIES[:ot_o   ].define_singleton_method(:receive, &ONLY_TT_BLOCK)

    NUMERIC_OBJECTS = [
      "1_234.5e4f",
      "1_234_567.1234e+40",
      "1_234",
      "123456789_123456789_123456789_123456789_123456789",
      "1234L",
      "1,234,567",
      "1_234.5e4",
    ]

    class FactoryBencher
      def benchmark_factory(factories)
        NUMERIC_OBJECTS.each do |obj|
          puts "=== Converting +%-20s+: %s" % [
            obj.inspect, factories.map{|fn, fact| "#{fn}: #{fact.receive(obj) rescue '(err)'}" }.join(" | ")]
        end
          NUMERIC_OBJECTS.each do |obj|
        Benchmark.ips(1.0, 0.2) do |bench|
            # bench.report('ot_o inline', "::Gorillib::Factory::NUMERIC_FACTORIES[:ot_o   ].receive(#{obj.inspect})")
            # bench.report('ot_o blk'){   ::Gorillib::Factory::NUMERIC_FACTORIES[:ot_o   ].receive(obj) }
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
    end

    bencher = FactoryBencher.new.benchmark_factory(NUMERIC_FACTORIES)

    # class SimplerFactory < IntegerFactory
    #   def receive(obj)
    #     obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
    #     obj = ::Kernel::Float(obj) if ::Gorillib::Factory::FLT_NOT_INT_RE === obj ;
    #     ::Kernel::Integer(obj)
    #   end
    # end
    # SIMPLER_BLOCK = ->(obj) do
    #     obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
    #     obj = ::Kernel::Float(obj) if ::Gorillib::Factory::FLT_NOT_INT_RE === obj ;
    #     ::Kernel::Integer(obj)
    # end
    #
    # class NovarFactory < IntegerFactory
    #   def receive(obj)
    #     obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '')
    #     if ::Gorillib::Factory::FLT_NOT_INT_RE === obj
    #       ::Kernel::Integer(::Kernel::Float(obj))
    #     else
    #       ::Kernel::Integer(obj)
    #     end
    #   end
    # end
    # NOVAR_BLOCK = ->(obj) do
    #     obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '')
    #     if ::Gorillib::Factory::FLT_NOT_INT_RE === obj
    #       ::Kernel::Integer(::Kernel::Float(obj))
    #     else
    #       ::Kernel::Integer(obj)
    #     end
    # end
    #
    # class AlwaysFactory < IntegerFactory
    #   def receive(obj)
    #     obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '')
    #     ::Kernel::Integer(::Kernel::Float(obj))
    #   end
    # end
    # ALWAYS_BLOCK = ->(obj) do
    #     obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '')
    #     ::Kernel::Integer(::Kernel::Float(obj))
    # end

    # :si             => SimplerFactory.new(),
    # :si_blk          => SimplerFactory.new(),
    # :nv             => NovarFactory.new(),
    # :nv_blk          => NovarFactory.new(),
    #
    # :si_o           => Object.new(),
    # :nv_o           => Object.new(),
    # :al             => AlwaysFactory.new(),
    # :al_blk          => AlwaysFactory.new(),

    # NUMERIC_FACTORIES[:si_blk ].define_singleton_method(:receive, &SIMPLER_BLOCK)
    # NUMERIC_FACTORIES[:si_o   ].define_singleton_method(:receive, &SIMPLER_BLOCK)
    # NUMERIC_FACTORIES[:nv_blk ].define_singleton_method(:receive, &NOVAR_BLOCK)
    # NUMERIC_FACTORIES[:nv_o   ].define_singleton_method(:receive, &NOVAR_BLOCK)
    # NUMERIC_FACTORIES[:al_blk ].define_singleton_method(:receive, &ALWAYS_BLOCK)

  end
end
