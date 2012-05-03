# describe 'Gorillib::Record::Overlay' do
#
#
#   context '.layer' do
#     it 'behaves like a gettersetter collection method'
#   end
#
#   context '.layers' do
#     it "returns the layered objects, highest-priority first."
#   end
#
#   context 'setting an attribute' do
#     it 'sets the value on the object'
#     it 'leaves the other layers intact'
#   end
#
#   context "reading an attribute (with no resolution block)" do
#     it "if set, returns the object's value"
#     it "if unset, returns the first value that is found"
#     it "if unset, and no layer has a value, returns nil"
#   end
#
#   context "reading an attribute (with resolution block)" do
#     it "calls the resolution block with the values from all layers in order"
#     it "returns the value the block responds with"
#   end
#
# end
#
#
# class Params
# end
#
# class CommandlineParams
# end
#
# class EnvVarParams
# end
#
# class CompositeParams
#   layer CommandlineParams, [:x, :y, :z]
#   layer EnvVarParams, [:x, :y, :z]
#
#   field :x
#   field :y
# end
