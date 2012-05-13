# -*- ruby -*-

# guard 'yard' do
#   watch(%r{lib/.+\.rb})
#   watch(%r{notes/.+\.(md|txt)}) { "notes" }
# end

# '--format doc'     for more verbose, --format progress for less
# '--tag record_spec' to only run tests tagged :record_spec
format  = "doc" # progress"
tags    = %w[ builder_spec ] # record_spec   example_spec ]
rspec_opts = "--format #{format} #{ tags.map{|tag| "--tag #{tag}"}.join(" ")  }"

guard 'rspec', :version => 2, :cli => rspec_opts do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^(examples/.+)\.rb})   {|m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/gorillib/(.+)\.rb$})       {|m| ["spec/gorillib/#{m[1]}_spec.rb", "spec/examples/builder/ironfan_spec.rb"] }
  watch('spec/spec_helper.rb')    {    "spec" }
  watch(/spec\/support\/(.+)\.rb/){    "spec" }
end
