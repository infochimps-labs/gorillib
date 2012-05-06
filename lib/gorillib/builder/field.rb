module Gorillib
  module Builder
    class MemberField < Gorillib::Record::Field
      #
      #
      #
      def inscribe_methods(record)
        fn   = self.name
        type = self.type
        record.__send__(:define_meta_module_method, fn,              visibility(:reader)  ) do |*args, &block|
          ArgumentError.check_arity!(args, 0..1)
          p [self, args, block]
          if args.empty?
            val = read_attribute(fn)
          else
            val = write_attribute(fn, args.first)
          end
          if block_given? && attribute_set?(fn)
            (block.arity == 1) ? block.call(val) : val.instance_eval(&block)
          end
          val
        end
        record.__send__(:define_meta_module_method, "receive_#{fn}", visibility(:receiver)) do |val|
          val = type.receive(val)
          write_attribute(fn, val)
          self
        end
      end
    end


    class CollectionField < Gorillib::Record::Field
      #
      #
      #
      def inscribe_methods(record)
        fn   = self.name
        type = self.type
        record.__send__(:define_meta_module_method, fn,              visibility(:reader)  ) do |*args|
          ArgumentError.check_arity!(args, 0..1)
          if args.empty?
            val = read_attribute(fn)
          else
            val = write_attribute(fn, args.first)
          end

        end
        record.__send__(:define_meta_module_method, "receive_#{fn}", visibility(:receiver)) do |val|
          val = type.receive(val)
          write_attribute(fn, val)
          self
        end
      end
    end
    
  end
end
