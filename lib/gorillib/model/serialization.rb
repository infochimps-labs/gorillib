module Gorillib
  module Model

    module ClassMethods
      def from_tuple(*vals)
        receive Hash[field_names[0..vals.length].zip(vals)]
      end
    end
  end
end
