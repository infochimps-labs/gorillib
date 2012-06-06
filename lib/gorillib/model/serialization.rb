module Gorillib
  module Model

    def to_wire(options={})
      attributes.merge(:_type => self.class.typename).inject({}) do |acc, (key,attr)|
        acc[key] = attr.respond_to?(:to_wire) ? attr.to_wire(options) : attr
        acc
      end
    end

    def to_json(options={})
      MultiJson.dump(to_wire(options), options)
    end
    alias_method(:as_json, :to_wire)

    module ClassMethods
      def from_tuple(*vals)
        receive Hash[field_names[0..vals.length].zip(vals)]
      end
    end

  end
end
