require 'time'
require 'date'
class Time
  # strftime() format to flatten a date
  FLAT_FORMAT = "%Y%m%d%H%M%S" unless defined?(FLAT_FORMAT)

  # Flatten
  def to_flat
    utc.strftime(FLAT_FORMAT)
  end unless method_defined?(:to_flat)
end

class DateTime < Date
  # strftime() format to flatten a date
  FLAT_FORMAT = "%Y%m%d%H%M%S" unless defined?(FLAT_FORMAT)

  # Flatten
  def to_flat
    to_time.utc.strftime(FLAT_FORMAT)
  end unless method_defined?(:to_flat)
end

class Date
  # strftime() format to flatten a date
  FLAT_FORMAT = "%Y%m%d" unless defined?(FLAT_FORMAT)

  # Flatten
  def to_flat
    strftime(FLAT_FORMAT)
  end unless method_defined?(:to_flat)
end
