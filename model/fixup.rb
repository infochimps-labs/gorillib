::Gorillib::Model::Field.class_eval do
  field :fixup, Symbol, doc: 'key to remap before receive', tester: true
end

module ::Gorillib::StringFixup
  extend Gorillib::Concern
  
  # intercept to replace fixup-able hash keys with the proper field name in the receive hash
  def receive!(hsh={})
    self.class.fields.each do |field_name, field|
      next unless field.fixup?
      hsh[field_name] = hsh.delete(field.fixup) if hsh.has_key?(field.fixup)
    end
    super(hsh)
  end
end