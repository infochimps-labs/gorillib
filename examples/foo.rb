module Gorillib
  module Test
    class Facet  ; include Gorillib::Builder ; end
    class Server ; include Gorillib::Builder ; end

    class Cluster
      include Gorillib::Builder

      collection :facets, Facet
    end

    class Facet
      include Gorillib::Builder
      member     :cluster, Cluster
      collection :servers, Server
    end

    class Server
      include Gorillib::Builder
      member     :cluster, Cluster
      member     :facet,   Facet
    end
  end
end
