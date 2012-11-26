module IpAddresslike
  ONES = 0xFFFFFFFF

  # Masks off all but the `bitness` most-significant-bits
  #
  # @example /24 keeps only the first three quads
  #   IpAddress.new('1.2.3.4').bitness_min(24) # '1.2.3.0'
  #
  def bitness_min(bitness)
    raise ArgumentError, "IP addresses have only 32 bits (got #{bitness.inspect})" unless (0..32).include?(bitness)
    lsbs = 32 - bitness
    (packed >> lsbs) << lsbs
  end

  # Masks off all but the `bitness` most-significant-bits, filling with ones
  #
  # @example /24 fills the last quad
  #   IpAddress.new('1.2.3.4').bitness_min(24) # '1.2.3.255'
  #
  def bitness_max(bitness)
    raise ArgumentError, "IP addresses have only 32 bits (got #{bitness.inspect})" unless (0..32).include?(bitness)
    packed | (ONES >> bitness)
  end

  def to_hex
    "%08x" % packed
  end

  def to_s
    dotted
  end

end

class ::IpAddress < ::String
  include IpAddresslike

  def dotted
    self
  end

  def to_i
    packed
  end

  # @returns [Integer] the 32-bit integer for this IP address
  def packed
    ip_a, ip_b, ip_c, ip_d = quads
    ((ip_a << 24) + (ip_b << 16) + (ip_c << 8) + (ip_d))
  end

  def quads
    self.split(".", 4).map{|qq| Integer(qq) }
  end

  # === class methods ===

  def self.from_packed(pi)
    str = [ (pi >> 24) & 0xFF, (pi >> 16) & 0xFF, (pi >>  8) & 0xFF, (pi) & 0xFF ].join(".")
    new(str)
  end

  def self.from_dotted(str)
    new(str)
  end
end

# Stores an IP address in numeric form.
#
# IpNumeric instances are immutable, and memoize most of their methods.
class ::IpNumeric
  include IpAddresslike
  include Comparable

  def receive(val)
    new(val)
  end

  def initialize(addr)
    @packed = addr.to_int
  end

  def to_i       ; packed ; end
  def to_int     ; packed ; end
  def ==(other)  ; packed  == other.to_int ; end
  def <=>(other) ; packed <=> other.to_int ; end
  def +(int)     ; self.class.new(to_int + int) ; end


  def packed ; @packed ; end

  def dotted
    @dotted ||= quads.join('.').freeze
  end

  def quads
    @quads ||= [ (@packed >> 24) & 0xFF, (@packed >> 16) & 0xFF, (@packed >>  8) & 0xFF, (@packed) & 0xFF ].freeze
  end

  # === class methods ===

  def self.from_packed(pi)
    new(pi)
  end

  def self.from_dotted(dotted)
    ip_a, ip_b, ip_c, ip_d = quads = dotted.split(".", 4).map(&:to_i)
    obj = new((ip_a << 24) + (ip_b << 16) + (ip_c << 8) + (ip_d))
    obj.instance_variable_set('@dotted', dotted.freeze)
    obj.instance_variable_set('@quads',  quads.freeze)
    obj
  end
end

class ::IpRange < Range

  def initialize(min_or_range, max=nil, exclusive=false)
    if max.nil?
      min       = min_or_range.min
      max       = min_or_range.max
      exclusive = min_or_range.exclude_end?
    else
      min       = min_or_range
    end
    raise ArgumentError, "Only inclusive #{self.class.name}s are implemented" if exclusive
    super( IpNumeric.new(min), IpNumeric.new(max), false )
  end

  def bitness_blocks(bitness)
    raise ArgumentError, "IP addresses have only 32 bits (got #{bitness.inspect})" unless (0..32).include?(bitness)
    return [] if min.nil?
    lsbs = 32 - bitness
    middle_min = min.bitness_max(bitness) + 1
    return [[min, max]] if max < middle_min
    middle_max = max.bitness_min(bitness)
    blks = []
    stride = 1 << lsbs
    #
    blks << [min, IpNumeric.new(middle_min-1)]
    (middle_min ... middle_max).step(stride){|beg| blks << [IpNumeric.new(beg), IpNumeric.new(beg+stride-1)] }
    blks << [IpNumeric.new(middle_max), max]
    blks
  end

  CIDR_RE = %r{\A(\d+\.\d+\.\d+\.\d+)/([0-3]\d)\z}

  def self.from_cidr(cidr_str)
    cidr_str =~ CIDR_RE or raise ArgumentError, "CIDR string should look like an ip address and bitness, eg 1.2.3.4/24 (got #{cidr_str})"
    bitness    = $2.to_i
    ip_address = IpNumeric.from_dotted($1)
    new( ip_address.bitness_min(bitness), ip_address.bitness_max(bitness) )
  end
end
