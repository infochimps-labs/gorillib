module Gorillib::Test
  def self.cluster(name=nil, attrs={}, &block)
    @example_cluster ||= Cluster.new(attrs.merge(:name => name))
    @example_cluster.instance_exec(&block) if block
    @example_cluster
  end

  class IronfanBuilder
    include Gorillib::FancyBuilder
    field 	    :name,        Symbol

  end
  class ComputeBuilder < IronfanBuilder; end

  class Organization   < IronfanBuilder ; end
  class Provider       < IronfanBuilder ; end
  class Cluster        < ComputeBuilder ; end
  class Facet          < ComputeBuilder ; end
  class Server         < ComputeBuilder ; end
  class Volume         < IronfanBuilder ; end
  class Cloud          < IronfanBuilder ; end
  class SecurityGroup  < IronfanBuilder ; end
  class Component      < IronfanBuilder ; end
  class Aspect         < IronfanBuilder ; end
  class Machine        < IronfanBuilder ; end
  class ChefNode       < IronfanBuilder ; end

  class ComputeBuilder < IronfanBuilder
    field         :environment, Symbol
    collection    :clouds,      Cloud
    collection    :volumes,    Volume
    collection    :components, Component
  end

  class Cluster        < ComputeBuilder
    collection    :facets,    Facet
    belongs_to    :organization, Organization

    def servers
      organization.servers.where(:cluster_name => self.name)
    end
  end

  module Cluster::Deprecated
    def find_facet(facet_name)
      facets.fetch(facet_name){ raise("Facet '#{facet_name}' is not defined in cluster '#{self.name}'") }
    end
  end

  class Facet          < ComputeBuilder
    belongs_to    :cluster,   Cluster
    collection    :servers,   Server
    field         :instances, Integer, :doc => 'number of servers to instantiate for this machine'
  end

  class Server         < ComputeBuilder
    belongs_to    :cluster,   Cluster
    belongs_to    :facet,     Facet
    member        :machine,   Machine
    member        :chef_node, ChefNode
  end

  class Volume         < IronfanBuilder
  end

  class Cloud          < IronfanBuilder
  end

  class Component      < IronfanBuilder
    field :discovers, Array, :of => :whatever, :doc => 'components this one discovers. Can be used to intelligently generate security groups, add client components, etc'
  end

  class SecurityGroup  < IronfanBuilder
  end

  class Universe  < IronfanBuilder
    collection  :organizations, Organization
    collection  :providers,     Provider
  end

  class Organization   < IronfanBuilder
    collection  :chef_nodes,    ChefNode
  end

  class Provider       < IronfanBuilder
    collection  :limbo_servers, Server
    collection  :clusters,      Cluster
    collection  :machines,      Machine
  end

  cluster(:yellowhat) do
    environment   :prod

    facet(:webnode) do
      instances  12
      volume(:logs) do
      end
      server(:a)
    end
    facet(:dbnode) do
      environment nil
    end

    facet(:esnode) do
    end
  end
end
