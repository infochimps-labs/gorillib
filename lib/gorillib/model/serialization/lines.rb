module Gorillib
  module Model

    module LoadLines
      extend Gorillib::Concern

      module ClassMethods

        # Iterate a block over each line of a file
        # @yield each line in the file.
        def _each_raw_line(filename, options={})
          filename = Pathname.path_to(filename)
          #
          pop_headers = options.delete(:pop_headers)
          #
          File.open(filename) do |file|
            file.readline if pop_headers
            file.each do |line|
              line.chomp! ; next if line.empty?
              yield line
            end
            nil
          end
        end

      end
    end

  end
end
