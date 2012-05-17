require 'spec_helper'
require 'gorillib/pathname'

describe Pathname do
  let(:mock_path){ mock(:path) }  # "We mock what we don't understand"

  context '.path_to' do
    subject{ described_class }
    before do
      subject.register_path(:doctor,  'doctor/doctor')
      subject.register_path(:code,    'twenty-square-digit', 'boustrophedonic')
      subject.register_path(:hello,   :doctor, :doctor)
      subject.register_path(:oh_crap, '~/ninjas')
      subject.register_path(:access,  '/would/you/like/to')
    end

    context 'examples' do
      { ['/tmp', :code]                      => '/tmp/twenty-square-digit/boustrophedonic',
        [:oh_crap]                           => ENV['HOME']+'/ninjas',
        [:hello, 'doctor', :doctor, :doctor] => File.expand_path('doctor/doctor/doctor/doctor/doctor/doctor/doctor/doctor/doctor'),
        [:oh_crap, :doctor]                  => File.join(ENV['HOME'], 'ninjas', 'doctor', 'doctor'),
        [".."]                               => File.expand_path('..'),
        ["..", 'bob']                        => File.expand_path(File.join('..', 'bob')),
      }.each do |input, expected|
        it 'expands symbols' do
          subject.path_to(*input).should == Pathname.new(expected)
        end
      end
    end

    it 'delays evaluation of path segments' do
      subject.register_path(:russia,  '/ussr/russia')
      subject.register_path(:city,    'leningrad')
      subject.register_path(:ermitage, :russia, :city)
      subject.path_to(:ermitage).should == Pathname.new('/ussr/russia/leningrad')
      subject.register_path(:city,    'st_petersburg')
      subject.path_to(:ermitage).should == Pathname.new('/ussr/russia/st_petersburg')
    end

    it 'expands all paths into a pathname' do
      subject.should_receive(:expand_pathseg).with(:a).and_return('/a')
      subject.should_receive(:expand_pathseg).with('b').and_return('b')
      subject.path_to(:a, 'b').should == Pathname.new('/a/b')
    end

    it 'expands relative paths' do
      FileUtils.cd '/' do
        subject.path_to(:hello).should == Pathname.new('/doctor/doctor/doctor/doctor')
      end
    end

    it 'collapses "//" double slashes' do
      subject.path_to('/', :access, '//have', 'a//pepsi').should == Pathname.new('/would/you/like/to/have/a/pepsi')
    end

    it 'must have at least one segment' do
      lambda{ subject.new() }.should raise_error(ArgumentError, /wrong number of arguments/)
    end
  end

  context '.relative_path_to' do
    subject{ described_class }

    it 'collapses "//" double slashes and useless ".." dots, but does not use the filesystem' do
      subject.relative_path_to('/', '../..', :access, '//have', 'a//pepsi').should == Pathname.new('/would/you/like/to/have/a/pepsi')
    end

    it 'does not expand relative paths' do
      FileUtils.cd '/' do
        subject.register_path(:hello,  'doctor')
        subject.relative_path_to(:hello, :hello, :hello).should == Pathname.new('doctor/doctor/doctor')
      end
    end
  end


  context 'registering paths' do
    subject { described_class }
    def expand_pathseg(*args) ; subject.send(:expand_pathseg, *args) ;  end
    
    context '.register_path' do
      it 'stores a path so expand_pathseg can get it later' do
        subject.register_path(:probe, ['skeletal', 'girth'])
        expand_pathseg(:probe).should == ['skeletal', 'girth']
      end
      it 'stores a list of path segments to re-expand' do
        subject.register_path(:ace, 'tomato', 'corporation')
        expand_pathseg(:ace).should == ['tomato', 'corporation']
      end
      it 'replaces the stored path if called again' do
        subject.register_path(:glg_20, 'boyer')
        subject.register_path(:glg_20, ['milbarge', 'fitz-hume'])
        expand_pathseg(:glg_20).should == ['milbarge', 'fitz-hume']
      end
    end
    
    context '.register_paths' do
      let(:paths) { { :foo => ['foo'], :bar => [:foo, 'bar'] } }
      
      it 'registers multiple paths' do
        subject.should_receive(:register_path).exactly(paths.size).times
        subject.register_paths(paths)
      end
    end
  end
end
