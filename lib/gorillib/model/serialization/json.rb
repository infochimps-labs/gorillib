require_relative './lines'

module Gorillib
  module Model

    module LoadFromJson
      extend  Gorillib::Concern
      include LoadLines

      module ClassMethods

        # Iterate a block over each line of a file having JSON records, one per
        # line, in a big stack
        #
        # @yield an object instantiated from each line in the file.
        def _each_from_json(filename, options={})
          _each_raw_line(filename, options) do |line|
            hsh = MultiJson.load(line)
            yield receive(hsh)
          end
        end

        # With a block, calls block on each object in turn (and returns nil)
        #
        # With no block, accumulates all the instances into the array it
        # returns. As opposed to the with-a-block case, the memory footprint of
        # this increases as the filesize does, so use caution with large files.
        #
        # @return with a block, returns nil; with no block, an array of this class' instances
        def load_json(*args)
          if block_given?
            _each_from_json(*args, &Proc.new)
          else
            objs = []
            _each_from_json(*args){|obj| objs << obj }
            objs
          end
        end

      end
    end

  end
end
