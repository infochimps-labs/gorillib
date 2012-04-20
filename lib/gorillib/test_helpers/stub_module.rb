# spec/spec_helper_lite.rb

# Conditionally creates empty or "stub" modules only if
# a) they are not already defined; and
# b) they are not auto-loadable.
#
# From http://objectsonrails.com/#sec-7-1
#
# @example Faking out ActiveModel
#    # ...
#    require_relative '../spec_helper_lite'
#    stub_module 'ActiveModel::Conversion'
#    stub_module 'ActiveModel::Naming'
#    require_relative '../../app/models/post'
#    # ...
#
def stub_module(full_name)
  # Uses #const_get to attempt to reference the given module. If the module is
  # defined, or if calling #const_get causes it to be auto-loaded, the method
  # does nothing more. But if #const_get fails to turn up the module, it defines
  # an anonymous empty module to act as a placeholder.
  full_name.to_s.split(/::/).inject(Object) do |context, name|
    begin
      context.const_get(name)
    rescue NameError
      context.const_set(name, Module.new)
    end
  end
end


# refute
# does_not_allow
