# -*- ruby -*-

# guard 'yard' do
#   watch(%r{lib/.+\.rb})
#   watch(%r{notes/.+\.(md|txt)}) { "notes" }
# end

# '--format doc'     for more verbose, --format progress for less
# '--tag record_spec' to only run tests tagged :record_spec
rspec_opts = '--format doc --tag record_spec'

guard 'rspec', :version => 2, :cli => rspec_opts do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})            { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')         { "spec" }
  watch(/spec\/support\/(.+)\.rb/)     { "spec" }
  watch(%r{^examples/(\w+)\.rb$})      { |m| "spec/examples/#{m[1]}_spec.rb" }
  watch(%r{^examples/(\w+)/(.+)\.rb$}) { |m| "spec/examples/#{m[1]}_spec.rb" }
end
