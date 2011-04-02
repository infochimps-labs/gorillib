class Object
  ##
  # Returns true if the object is nil or empty (if applicable)
  #
  #   [].blank?         #=>  true
  #   [1].blank?        #=>  false
  #   [nil].blank?      #=>  false
  #
  # @return [TrueClass, FalseClass]
  #
  def blank?
    nil? || (respond_to?(:empty?) && empty?)
  end

  ##
  # Returns true if the object is NOT nil or empty
  #
  #   [].present?         #=>  false
  #   [1].present?        #=>  true
  #   [nil].present?      #=>  true
  #
  # @return [TrueClass, FalseClass]
  #
  def present?
    not blank?
  end
end # class Object

class Numeric
  ##
  # Numerics are never blank
  #
  #   0.blank?          #=>  false
  #   1.blank?          #=>  false
  #   6.54321.blank?    #=>  false
  #
  # @return [FalseClass]
  #
  def blank?
    false
  end
end # class Numeric

class NilClass
  ##
  # Nil is always blank
  #
  #   nil.blank?        #=>  true
  #
  # @return [TrueClass]
  #
  def blank?
    true
  end
end # class NilClass

class TrueClass
  ##
  # True is never blank.
  #
  #   true.blank?       #=>  false
  #
  # @return [FalseClass]
  #
  def blank?
    false
  end
end # class TrueClass

class FalseClass
  ##
  # False is always blank.
  #
  #   false.blank?      #=>  true
  #
  # @return [TrueClass]
  #
  def blank?
    true
  end
end # class FalseClass

class String
  ##
  # Strips out whitespace then tests if the string is empty.
  #
  #   "".blank?         #=>  true
  #   "     ".blank?    #=>  true
  #   " hey ho ".blank? #=>  false
  #
  # @return [TrueClass, FalseClass]
  #
  def blank?
    strip.empty?
  end
end # class String
