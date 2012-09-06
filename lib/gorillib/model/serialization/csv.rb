require 'csv'
require 'gorillib/pathname'

module Gorillib
  module Model

    module LoadFromCsv
      extend Gorillib::Concern
      included do |base|
        # Options that will be passed to CSV. Be careful to modify with assignment (`+=`) and not in-place (`<<`)
        base.class_attribute :csv_options
        base.csv_options = Hash.new
      end

      module ClassMethods

        # Iterate a block over each line of a CSV file
        #
        # @raise [Gorillib::Model::RawDataMismatchError] if a line has too many or too few fields
        # @yield an object instantiated from each line in the file.
        def each_in_csv(filename, options={})
          filename = Pathname.path_to(filename)
          options = csv_options.merge(options)
          pop_headers = options.delete(:pop_headers)
          num_fields  = options.delete(:num_fields){ (fields.length .. fields.length) }
          raise ArgumentError, "The :headers option to CSV changes its internal behavior; use 'pop_headers: true' to ignore the first line" if options[:headers]
          CSV.open(filename, options) do |csv_file|
            csv_file.shift if pop_headers
            csv_file.each do |tuple|
              next if tuple.empty?
              unless num_fields.include?(tuple.length) then raise Gorillib::Model::RawDataMismatchError, "yark, spurious fields: #{tuple.inspect}" ; end
              yield from_tuple(*tuple)
            end
            nil
          end
        end

        # With a block, calls block on each object in turn (and returns nil)
        #
        # With no block, accumulates all the instances into the array it
        # returns. As opposed to the with-a-block case, the memory footprint of
        # this increases as the filesize does, so use caution with large files.
        #
        # @return with a block, returns nil; with no block, an array of this class' instances
        def load_csv(*args)
          if block_given?
            each_in_csv(*args, &Proc.new)
          else
            objs = []
            each_in_csv(*args){|obj| objs << obj }
            objs
          end
        end

      end
    end

  end
end
