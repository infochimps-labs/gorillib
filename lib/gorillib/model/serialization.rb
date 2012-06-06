module Gorillib
  module Model

    def to_json(options={})
      p [options, self]
      attributes.inject({}) do |acc, (key,attr)|
        acc[key] = MultiJson.dump(attr, options)
        acc
      end
    end

    module ClassMethods
      def from_tuple(*vals)
        receive Hash[field_names[0..vals.length].zip(vals)]
      end
    end

  end
end
