shared_context 'included_module' do
  
  let(:included_module) { described_class }
  let(:klass_name)      { 'FakeModel'     }
  
  def create_fake_model_klass name
    klass = self.class.const_set(name.to_sym, Class.new)
    mod   = included_module
    klass.class_eval{ include(mod) }
    klass
  end
  
  def remove_fake_model_klass name
    self.class.send(:remove_const, name.to_sym) if self.class.const_defined? name.to_sym
  end

  subject      { create_fake_model_klass(klass_name) }
  after(:each) { remove_fake_model_klass(klass_name) }
 
end
