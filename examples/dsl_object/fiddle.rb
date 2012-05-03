require 'dm-core'
module Ironfan
class Ironfan::Cluster
  include LayeredRecord
  layer :cloud
  layer :facet
  layer :server
  #
  property :environment, Symbol, :layered => [:cloud, :facet, :server], :description => 'chef environment'
  property :bogosity,    Symbol, :layered => [:cloud, :facet, :server], :description => 'set the bogosity to a descriptive reason. Anything truthy implies bogusness'
  #
  has :n, :volumes,   Ironfan::Volume
  has :n, :components, Ironfan::Component, :description => 'system components to assemble'
  #
  def bogus?
    !! self.bogosity
  end
  layer_property(:facet, :bogus?)
end

class Ironfan::Facet
  include LayeredRecord
  #
  property :instances, Integer, :description => 'number of servers in this facet'
end

class Ironfan::Server
  include LayeredRecord
  #
  property :cluster,     Ironfan::Cluster
  property :facet,       Ironfan::Facet
  property :facet_index, Integer
  property :tags,        Array, :of => Symbol
  #
  attr_reader :chef_node
  attr_reader :machine
  #
end

# Ironfan.cluster(:awesome_app) do
#
#
#   facet(:webnode) do
#
#   end
# end

end
