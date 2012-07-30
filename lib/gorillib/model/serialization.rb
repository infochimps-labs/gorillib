class Array
  def to_tsv
    join("\t")
  end
end

module Gorillib
  module Model
    def to_wire(options={})
      attributes.merge(:_type => self.class.typename).inject({}) do |acc, (key,attr)|
        acc[key] = attr.respond_to?(:to_wire) ? attr.to_wire(options) : attr
        acc
      end
    end
    def as_json(*args) to_wire(*args) ; end

    def to_json(options={})
      MultiJson.dump(to_wire(options), options)
    end

    def to_tsv
      attribute_values.map(&:to_s).join("\t")
    end

    module ClassMethods
      def from_tuple(*vals)
        receive Hash[field_names[0..vals.length].zip(vals)]
      end
    end

  end
end
