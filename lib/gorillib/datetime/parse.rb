class Time
  #
  # Parses the time but never fails.
  # Return value is always in the UTC time zone.
  #
  # A flattened datetime -- a 14-digit YYYYmmddHHMMMSS -- is fixed to the UTC
  # time zone by parsing it as YYYYmmddHHMMMSSZ <- 'Z' at end
  #
  def self.parse_safely dt
    return nil if dt.blank?
    begin
      case
      when dt.is_a?(Time)               then dt.utc
      when (dt.to_s =~ /\A\d{14}\z/)    then parse(dt.to_s+'Z', true)
      else                                   parse(dt.to_s,     true).utc
      end
    rescue StandardError => e
      Log.debug e
    end
  end unless method_defined?(:parse_safely)
end
