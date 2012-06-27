require 'gorillib'

class DslObject

  class_attribute :properties
  self.properties = {}

  def self.property(name, opts={})
    unless method_defined? name
      define_method(name) do |val=nil|
        set(name, val) unless val.nil?
        get(name)
      end
      self.properties[name.to_sym] = opts[:default] || nil
    end
  end

  def initialize(attrs={})
    define_properties!(attrs)
    impose_defaults!
    self
  end

  def configure(attrs={}, &block)
    define_properties!(attrs)
    instance_eval(&block) if block
    self
  end

  def set(property, val)
    instance_variable_set("@" + property.to_s, val)
  end
  
  def get(property)
    instance_variable_get("@" + property.to_s)
  end

  def set?(property)
    instance_variable_defined?("@" + property.to_s)
  end

  def unset!(property)
    remove_instance_variable("@" + property.to_s) if set?(property)
  end

  def to_hash
    self.properties.inject({}){ |hsh,(key,val)| hsh[key] = get(key) ; hsh }
  end

  def to_s
    "<#{self.class} #{to_hash.inspect}>"
  end
  
  private

  def impose_defaults!
    self.class.properties.each{ |key, val| set(key, val) unless set?(key) }
  end

  def define_properties!(hsh)
    hsh.each{ |name,val| self.class.property(name); set(name, val) }
  end

end
