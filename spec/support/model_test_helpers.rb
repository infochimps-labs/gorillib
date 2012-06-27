module Gorillib ;               module Test ;       end ; end
module Meta ; module Gorillib ; module Test ; end ; end ; end

shared_context 'model', :model_spec => true do
  after(:each){ Gorillib::Test.nuke_constants ; Meta::Gorillib::Test.nuke_constants }

  let(:mock_val){ mock('mock value') }

  let(:engine_class) do
    class Gorillib::Test::Engine
      include Gorillib::Builder
      magic    :name,         Symbol, :default => ->{ "#{owner? ? owner.name : ''} engine"}
      magic    :carburetor,   Symbol, :default => :stock
      magic    :volume,       Integer, :doc => 'displacement volume, in in^3'
      magic    :cylinders,    Integer
      member   :owner,        Whatever
      self
    end
    Gorillib::Test::Engine
  end

  let(:car_class) do
    engine_class
    class Gorillib::Test::Car
      include Gorillib::Builder
      magic    :name,          Symbol
      magic    :make_model,    String
      magic    :year,          Integer
      magic    :doors,         Integer
      member   :engine,        Gorillib::Test::Engine
      self
    end
    Gorillib::Test::Car
  end

  let(:garage_class) do
    car_class
    class Gorillib::Test::Garage
      include Gorillib::Builder
      collection :cars,       Gorillib::Test::Car
      self
    end
    Gorillib::Test::Garage
  end

  let(:wildcat) do
    car_class.receive( :name => :wildcat,
      :make_model => 'Buick Wildcat', :year => 1968, :doors => 2,
      :engine => { :volume => 455, :cylinders => 8 } )
  end
  let(:ford_39) do
    car_class.receive( :name => :ford_39,
      :make_model => 'Ford Tudor Sedan', :year => 1939, :doors => 2, )
  end
  let(:garage) do
    garage_class.new
  end
  let(:example_engine) do
    engine_class.new( :name => 'Geo Metro 1.0L', :volume => 61, :cylinders => 3 )
  end

end
