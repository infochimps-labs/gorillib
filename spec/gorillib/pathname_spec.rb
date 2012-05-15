require 'spec_helper'
require 'gorillib/pathname'

describe Pathname do
  subject{ described_class.new('a', 'b') }
  let(:pathref_subklass){ Class.new(described_class) }
  let(:mock_path){ mock(:path) }  # "We mock what we don't understand"

  context '.path_to' do
    before do
      described_class.register_path(:doctor,  'doctor/doctor')
      described_class.register_path(:code,    'twenty-square-digit', 'boustrophedonic')
      described_class.register_path(:hello,   :doctor, :doctor)
      described_class.register_path(:oh_crap, '~/ninjas')
    end
    { ['/tmp', :code]                      => '/tmp/twenty-square-digit/boustrophedonic',
      [:oh_crap]                           => ENV['HOME']+'/ninjas',
      [:hello, 'doctor', :doctor, :doctor] => File.expand_path('doctor/doctor/doctor/doctor/doctor/doctor/doctor/doctor/doctor'),
      [:oh_crap, :doctor]                  => File.join(ENV['HOME'], 'ninjas', 'doctor', 'doctor'),
      [".."]                               => File.expand_path('..'),
      ["..", 'bob']                        => File.expand_path(File.join('..', 'bob')),
    }.each do |input, expected|
      it 'expands symbols' do
        described_class.path_to(*input).should == Pathname.new(expected)
      end
    end

    it 'delays evaluation of path segments' do
      described_class.register_path(:russia,  '/ussr/russia')
      described_class.register_path(:city,    'leningrad')
      described_class.register_path(:ermitage, :russia, :city)
      described_class.path_to(:ermitage).should == Pathname.new('/ussr/russia/leningrad')
      described_class.register_path(:city,    'st_petersburg')
      described_class.path_to(:ermitage).should == Pathname.new('/ussr/russia/st_petersburg')
    end

    it 'expands all paths into a pathname' do
      described_class.should_receive(:expand_pathseg).with(:a).and_return('/a')
      described_class.should_receive(:expand_pathseg).with('b').and_return('b')
      described_class.path_to(:a, 'b').should == Pathname.new('/a/b')
    end

    it 'must have at least one segment' do
      lambda{ described_class.new() }.should raise_error(ArgumentError, /wrong number of arguments/)
    end
  end

  context '.register_path' do
    def expand_pathseg(*args) ; described_class.send(:expand_pathseg, *args) ;  end
    it 'stores a path so expand_pathseg can get it later' do
      described_class.register_path(:probe, ['skeletal', 'girth'])
      expand_pathseg(:probe).should == ['skeletal', 'girth']
    end
    it 'stores a list of path segments to re-expand' do
      described_class.register_path(:ace, 'tomato', 'corporation')
      expand_pathseg(:ace).should == ['tomato', 'corporation']
    end
    it 'replaces the stored path if called again' do
      described_class.register_path(:glg_20, 'boyer')
      described_class.register_path(:glg_20, ['milbarge', 'fitz-hume'])
      expand_pathseg(:glg_20).should == ['milbarge', 'fitz-hume']
    end
  end

end
