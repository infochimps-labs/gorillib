require_relative './lines'

module Gorillib
  module Model

    module LoadFromTsv
      extend  Gorillib::Concern
      include LoadLines

      included do |base|
        # Options that will be passed to CSV. Be careful to modify with assignment (`+=`) and not in-place (`<<`)
        base.class_attribute :tsv_options
        base.tsv_options = Hash.new
      end

      module ClassMethods

        # Iterate a block over each line of a TSV file
        #
        # @raise [Gorillib::Model::RawDataMismatchError] if a line has too many or too few fields
        # @yield an object instantiated from each line in the file.
        def _each_from_tsv(filename, options={})
          options = tsv_options.merge(options)
          num_fields  = options.delete(:num_fields){ (fields.length .. fields.length) }
          #
          _each_raw_line(filename, options) do |line|
            tuple = line.split("\t")
            unless num_fields.include?(tuple.length) then raise Gorillib::Model::RawDataMismatchError, "yark, spurious fields: #{tuple.inspect}" ; end
            yield from_tuple(*tuple)
          end
        end

        # With a block, calls block on each object in turn (and returns nil)
        #
        # With no block, accumulates all the instances into the array it
        # returns. As opposed to the with-a-block case, the memory footprint of
        # this increases as the filesize does, so use caution with large files.
        #
        # @return with a block, returns nil; with no block, an array of this class' instances
        def load_tsv(*args)
          if block_given?
            _each_from_tsv(*args, &Proc.new)
          else
            objs = []
            _each_from_tsv(*args){|obj| objs << obj }
            objs
          end
        end

      end
    end

  end
end
