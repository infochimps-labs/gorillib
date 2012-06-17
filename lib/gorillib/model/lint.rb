module Gorillib
  module Model
    #
    # A set of guards for good behavior:
    #
    # * checks that fields given to read_attribute, write_attribute, etc are defined
    #
    module Lint
      def read_attribute(field_name, *)  check_field(field_name) ; super ; end
      def write_attribute(field_name, *) check_field(field_name) ; super ; end
      def unset_attribute(field_name, *) check_field(field_name) ; super ; end
      def attribute_set?(field_name, *)  check_field(field_name) ; super ; end

    protected
      # @return [true] if the field exists
      # @raise [UnknownFieldError] if the field is missing
      def check_field(field_name)
        return true if self.class.has_field?(field_name)
        raise UnknownFieldError, "unknown field: #{field_name} for #{self}"
      end

    end
  end
end
