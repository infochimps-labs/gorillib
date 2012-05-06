module Gorillib
  module Builder
    extend  Gorillib::Concern
    include Gorillib::Record

    module ClassMethods
      def member(field_name, type, options={})
        field(field_name, type, options.merge(:field_type => ::Gorillib::Builder::MemberField))
      end

      def collection(field_name, type, options={})
        field(field_name, type, options.merge(:field_type => ::Gorillib::Builder::CollectionField))
      end
    end
  end
end
