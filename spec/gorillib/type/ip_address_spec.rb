require 'spec_helper'
require 'support/factory_test_helpers'
require 'gorillib/object/blank'
#
require 'gorillib/type/ip_address'

shared_examples_for(:ip_addresslike) do

  its(:dotted){ should == '1.2.3.4' }
  its(:quads){  should == [1, 2, 3, 4] }
  its(:packed){ should == packed_1234 }

  context '.from_packed' do
    subject{ described_class.from_packed(packed_1234) }
    it{ should be_a(described_class) }
    its(:dotted){ should == '1.2.3.4' }
  end

  context '#bitness_min' do
    it('is unchanged for /32'){ subject.bitness_min(32).should == subject.packed }
    {  0 => 0,          # '0.0.0.0'
       6 => 0,          # '0.0.0.0'
       8 => 0x01000000, # '1.0.0.0',
      30 => 0x01020304, # '1.2.3.4',
    }.each do |bitness, result|
      it("returns #{result} for #{bitness}"){ subject.bitness_min(bitness).should == result }
    end
    it 'raises an error if bitness is out of range' do
      expect{ subject.bitness_min(33)    }.to raise_error(ArgumentError, /only 32 bits.*33/)
      expect{ subject.bitness_min(-1)    }.to raise_error(ArgumentError, /only 32 bits.*-1/)
      expect{ subject.bitness_min('bob') }.to raise_error(ArgumentError, /only 32 bits.*bob/)
    end
  end

  context '#bitness_max' do
    it 'returns an integer' do
      subject.bitness_max(24).should equal(16909311)
    end
    it('is unchanged for /32'   ){ subject.bitness_max(32).should == subject.packed }
    {  0 => 0xFFFFFFFF, # '255.255.255.255'
       6 => 0x03FFFFFF, # '3.255.255.255'
       8 => 0x01FFFFFF, # '1.255.255.255'
      31 => 0x01020305, # '1.2.3.5'
    }.each do |bitness, result|
      it("returns #{result} for #{bitness}"){ subject.bitness_max(bitness).should == result }
    end
    it 'raises an error if bitness is out of range' do
      expect{ subject.bitness_max(33)    }.to raise_error(ArgumentError, /only 32 bits.*33/)
      expect{ subject.bitness_max(-1)    }.to raise_error(ArgumentError, /only 32 bits.*-1/)
      expect{ subject.bitness_max('bob') }.to raise_error(ArgumentError, /only 32 bits.*bob/)
    end
  end
end

describe ::IpAddress do
  let(:packed_1234){ 16909060 }
  let(:dotted_1234){ '1.2.3.4' }
  subject{ described_class.new('1.2.3.4') }

  it_should_behave_like(:ip_addresslike)

  its(:to_i){ should equal(packed_1234) }
  it{ expect{ subject.to_int }.to raise_error(NoMethodError, /undefined method.*\`to_int\'/) }
end

describe ::IpNumeric do
  let(:packed_1234){ 16909060 }
  let(:dotted_1234){ '1.2.3.4' }
  subject{ described_class.new(packed_1234) }

  it_should_behave_like(:ip_addresslike)

  context '.from_dotted' do
    subject{ described_class.from_dotted(dotted_1234) }
    it('memoizes #dotted') do
      val = subject.instance_variable_get('@dotted')
      val.should == '1.2.3.4'
      val.should be_frozen
    end
    it('memoizes #quads') do
      val = subject.instance_variable_get('@quads')
      val.should == [1,2,3,4]
      val.should be_frozen
    end
  end

end


describe ::IpRange do
  let(:beg_1234){ 16909060 }
  let(:end_1234){ 16909384 }
  subject{ described_class.new(beg_1234 .. end_1234) }

  its(:min){ should == beg_1234 }
  its(:max){ should == end_1234 }
  its(:min){ should be_a(IpNumeric) }
  its(:max){ should be_a(IpNumeric) }

  context 'bitness_blocks' do
    it 'emits nothing if empty' do
      described_class.new(50, 49).bitness_blocks(24).should == []
    end
    it 'emits only one block if min and max are in same bitness block' do
      described_class.new(40, 80).bitness_blocks(24).should == [ [40, 80] ]
    end
    it 'emits only one block if min and max are the same' do
      described_class.new(40, 40).bitness_blocks(24).should == [ [40, 40] ]
    end
    it 'emits two short blocks if min and max are in neighboring blocks' do
      described_class.new(40, 260).bitness_blocks(24).should == [ [40, 255], [256, 260] ]
    end
    it 'emits intermediate blocks if min and max are far apart' do
      described_class.new(40, 520).bitness_blocks(24).should == [ [40, 255], [256, 511], [512, 520] ]
    end

    {
      [ '255.255.255.255', '255.255.255.255',  0 ] => [ [0xFFFFFFFF, 0xFFFFFFFF] ],
      [ '255.255.255.255', '255.255.255.255', 24 ] => [ [0xFFFFFFFF, 0xFFFFFFFF] ],
      [ '255.255.255.255', '255.255.255.255', 32 ] => [ [0xFFFFFFFF, 0xFFFFFFFF] ],
      [ '255.255.254.1',   '255.255.255.255',  0 ] => [ [0xFFFFFe01, 0xFFFFFFFF] ],
      [ '255.255.254.1',   '255.255.255.255', 24 ] => [ [0xFFFFFe01, 0xFFFFFeFF], [0xFFFFFF00, 0xFFFFFFFF] ],
      [ '255.255.253.1',   '255.255.255.7',   24 ] => [ [0xFFFFFd01, 0xFFFFFdFF], [0xFFFFFe00, 0xFFFFFeFF], [0xFFFFFF00, 0xFFFFFF07] ],
      [ '0.0.0.0',         '0.0.0.0',         24 ] => [ [0x0,        0x0], ],
      [ '0.0.0.255',       '0.0.1.0',         24 ] => [ [0xFF, 0xFF], [0x100, 0x100] ],
      [ '0.0.0.7',         '0.0.0.10',        31 ] => [ [0x7, 0x7], [0x8, 0x9], [0xa, 0xa], ],
      [ '0.0.0.7',         '0.0.0.11',        31 ] => [ [0x7, 0x7], [0x8, 0x9], [0xa, 0xb], ],
      [ '0.0.0.0',         '0.0.0.0',         24 ] => [ [0x0,        0x0], ],
      [ '0.0.1.7',         '0.0.1.255',       24 ] => [ [0x107,      0x1FF], ],
      [ '0.0.1.7',         '0.0.2.7',         24 ] => [ [0x107,      0x1FF], [0x200, 0x207] ],
      [ '0.0.1.7',         '0.0.3.7',         24 ] => [ [0x107,      0x1FF], [0x200, 0x2FF], [0x300, 0x307] ],
    }.each do |(beg_ip, end_ip, bitness), blocks|
      it "/#{bitness}-bit blocks of #{beg_ip}..#{end_ip} are #{blocks}" do
        beg_ip = IpNumeric.from_dotted(beg_ip)
        end_ip = IpNumeric.from_dotted(end_ip)
        subject = IpRange.new(beg_ip .. end_ip)
        subject.bitness_blocks(bitness).should == blocks
      end
    end

  end

end
