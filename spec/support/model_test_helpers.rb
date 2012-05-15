module ::Gorillib::Scratch ; end
module ::Meta ; module Gorillib ; module Scratch ; end ; end ; end

shared_context 'model', :model_spec => true do
  let(:poppa_smurf   ){ Gorillib::Scratch::PoppaSmurf = Class.new{ include Meta::Type::ModelType } }
  let(:smurfette     ){ Gorillib::Scratch::Smurfette  = Class.new(poppa_smurf) }

  after do
    ::Gorillib::Scratch.nuke_constants
    ::Meta::Gorillib::Scratch.nuke_constants
  end
end
