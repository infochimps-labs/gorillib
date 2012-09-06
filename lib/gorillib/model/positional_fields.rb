module Gorillib
  module Model

    #
    # give each field the next position in order
    #
    # @example
    #   class Foo
    #     include Gorillib::Model
    #     field :bob,    String               # not positional
    #     field :zoe,    String, position: 0  # positional 0 (explicit)
    #   end
    #   class Subby < Foo
    #     include Gorillib::Model::PositionalFields
    #     field :wun, String                  # positional 1
    #   end
    #   Foo.field    :nope, String            # not positional
    #   Subby.field  :toofer, String          # positional 2
    #
    # @note: make sure you're keeping positionals straight in super classes, or
    # in anything added after this.
    #
    module PositionalFields
      extend Gorillib::Concern

      module ClassMethods
        def field(*args)
          options = args.extract_options!
          super(*args, {position: positionals.count}.merge(options))
        end
      end

    end
  end
end
