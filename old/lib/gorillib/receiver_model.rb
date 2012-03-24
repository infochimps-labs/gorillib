require 'gorillib/hashlike'
require 'gorillib/hashlike/tree_merge'
require 'gorillib/receiver'
require 'gorillib/receiver/acts_as_hash'
require 'gorillib/receiver/acts_as_loadable'
require 'gorillib/receiver/active_model_shim'

module Gorillib
  module ReceiverModel
    def self.included base
      base.class_eval do
        include Receiver
        include Receiver::ActsAsHash
        include Receiver::ActsAsLoadable
        include Gorillib::Hashlike
        include Gorillib::Hashlike::TreeMerge
        include Receiver::ActiveModelShim
      end
    end
  end
end
