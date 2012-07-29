module Gorillib::Test
  def self.cluster(name=nil, attrs={}, &block)
    @example_cluster ||= Cluster.new(attrs.merge(:name => name))
    @example_cluster.instance_exec(&block) if block
    @example_cluster
  end

  class IronfanBuilder
    include Gorillib::FancyBuilder
    magic           :name,        Symbol

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
  class ChefNode       < IronfanBuilder ; def save() ; end ; end

  module Ironfan
    class << self
      attr_reader :dry_run
      attr_reader :config
    end
    @dry_run = false
    @config  = {}
  end


  class ComputeBuilder < IronfanBuilder
    magic         :environment, Symbol
    collection    :clouds,     Cloud
    collection    :volumes,    Volume
    collection    :components, Component

    def run_list() ; end
  end

  class Cluster        < ComputeBuilder
    collection    :facets,    Facet
    belongs_to    :organization, Organization

    def servers() organization.servers.where(:cluster_name => self.name) ; end
  end

  class Facet          < ComputeBuilder
    belongs_to    :cluster,   Cluster
    collection    :servers,   Server
    magic         :instances, Integer, :doc => 'number of servers to instantiate for this machine'
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
    magic :discovers, Array, :of => :whatever, :doc => 'components this one discovers. Can be used to intelligently generate security groups, add client components, etc'
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

      servers     # <Gorillib::Collection { :a => <Server name=:a ... > } >
      server(:a)  # <Server name=:a ... > } >
    end

    facet(:dbnode) do
      environment nil
    end

    facet(:esnode) do
    end
  end
end
