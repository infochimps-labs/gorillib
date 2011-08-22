module Gorillib

  module Hashlike
    module Serialization
      #
      # Returns a hash with each key set to its associated value
      #
      # @example
      #    my_hshlike = MyHashlike.new
      #    my_hshlike[:a] = 100; my_hshlike[:b] = 200
      #    my_hshlike.to_hash # => { :a => 100, :b => 200 }
      #
      # @return [Hash] a new Hash instance, with each key set to its associated value.
      #
      def to_wire(options={})
        {}.tap do |hsh|
          each do |attr,val|
            hsh[attr] =
              case
              when val.respond_to?(:to_wire) then val.to_wire(options)
              when val.respond_to?(:to_hash) then val.to_hash
              else val ; end
          end
        end
      end
    end
  end
end

module Gorillib::Hashlike
  include ::Gorillib::Hashlike::Serialization
end

class ::Array
  def to_wire(options={})
    map{|item| item.respond_to?(:to_wire) ? item.to_wire : item }
  end
end

class ::Hash
  include ::Gorillib::Hashlike::Serialization
end

class ::Time
  def to_wire(options={})
    self.iso8601
  end
end


