require 'gorillib/model'
require 'gorillib/collection/has_collection'
require 'hanuman/stage'

# module WukongTest
#
#   class WorkflowBuilder
#     include Gorillib::FancyBuilder
#   end
#
#   class Utensil < Hanuman::Stage
#     field           :size,    String
#   end
#
#   class Container < Utensil
#   end
#
#   class Ingredient < Hanuman::Stage
#     field           :qty,  Integer
#   end
#
#   class Kitchen
#     include Gorillib::FancyBuilder
#     extend Gorillib::Collection::HasCollection
#   end
#
#   class CookingStep < Hanuman::Stage
#     # def utensils               ; Kitchen.utensils ; end
#     # def utensil(*args, &block) ; Kitchen.utensil(*args, &block) ; end
#     # def ingredient(*args)      ; Kitchen.ingredient(*args) ; end
#     # has_collection :utensils,    Utensil
#     collection     :utensils,    Utensil
#     collects       Container,    :utensil
#     collection     :ingredients, Ingredient
#   end
#
#   class AddToContainer < CookingStep
#     collection     :contents, Ingredient
#     member         :container, Container
#   end
#   class MixContents    < CookingStep ; end
#   class BakeInOven     < CookingStep ; end
#
#   class Chain < CookingStep
#     collection     :stages, Hanuman::Stage
#     collects       Chain,          :stage
#     collects       MixContents,    :stage
#     collects       BakeInOven,     :stage
#
#     def tree(options={})
#       options = {:indent => 0}.merge(options)
#       p ['tree', self, options]
#       indent_str = " " * options[:indent]
#       str = ["#{indent_str}#{name}"]
#       stages.to_a.each do |stage|
#         if stage.is_a?(Chain)
#           str << stage.tree(:indent => options[:indent] + 2)
#         else
#           str << "#{indent_str}  #{stage.name}"
#         end
#       end
#       str
#     end
#
#     def add_to_container(ctr_name, ingredients, &block)
#       x = stage(:add_to_container, {:owner => self}, :factory => AddToContainer)
#       stages << ingredient(ingredients.first)
#     end
#   end
#
#   class Workflow < Chain
#   end
#
#   extend Gorillib::Collection::HasCollection
#   has_collection(:workflow, Workflow)
#
#   workflow :cherry_pie do
#
#     chain :crust do
#
#       utensil :large_bowl
#       utensil :rolling_pin
#       utensil :pie_tin
#       utensil :cutting_board
#       utensil :saucepan
#       utensil :stove
#       utensil :oven
#       utensil :wire_rack
#
#       p [self, self.owner]
#       ingredient :flour,     :qty => '3 cups'
#       ingredient :sugar,     :qty => '2 tbsp'
#       ingredient :salt,      :qty => '1.5 tsp'
#       ingredient :butter,    :qty => '0.5 cups'
#       ingredient :buttermilk,:qty => '0.5 cups'
#
#       action(add).inputs(
#         utensil(:large_bowl),
#         ingredient(:flour),
#         ingredient(:sugar),
#         ingredient(:salt)
#         )
#
#       add_to_container :large_bowl, [:flour, :sugar, :salt]
#       # mix
#       # combine previous, :butter, :shortening
#       # mix     :until => 'resembles coarse crumbs'
#       # combine previous, :buttermilk
#       # mix     :until => 'resembles pastry'
#       # split   previous, :into => [:ball_1, :ball_2]
#       # refrigerate(wrap(:ball_1))
#       # refrigerate(wrap(:ball_2))
#     end
#
#     chain :filling do
#       ingredient :cherries,  :qty => '4 cups'
#       ingredient :cornstarch,:qty => '1/3 cup'
#       ingredient :sugar2,     :qty => '1.5 cups'
#       ingredient :salt2,      :qty => '1 dash'
#       ingredient :butter2,    :qty => '2 tbsp'
#
#       # drain :cherries, :into => ingredient(:cherry_juice, :qty => '1/2 cup')
#
#     end
#   end
# end
