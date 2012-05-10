require 'gorillib/record'
require 'gorillib/collection/has_collection'

module WukongTest

  class WorkflowBuilder
    include Gorillib::FancyBuilder
  end

  class Utensil
    include Gorillib::FancyBuilder
    field           :size,    String
  end

  class Container < Utensil
  end

  class Ingredient
    include Gorillib::FancyBuilder
    field           :qty,  Integer
  end

  class Kitchen
    include Gorillib::FancyBuilder
    extend Gorillib::Collection::HasCollection
    has_collection :utensils,    Utensil
    collects       Container,    :utensil
    has_collection :ingredients, Ingredient
  end

  class Stage          < WorkflowBuilder
    field          :input,   String
    field          :output,  String
    member         :from,    Stage
    member         :to,      Stage
    belongs_to     :owner,   Whatever

    def utensils ; Kitchen.utensils ; end
    def utensil(*args, &block) ; Kitchen.utensil(*args, &block) ; end

    def ingredient(*args) ; Kitchen.ingredient(*args) ; end
  end

  class CookingStep    < Stage ; end

  class AddToContainer < CookingStep
    collection     :contents, Ingredient
    member         :container, Container
  end
  class MixContents    < CookingStep ; end
  class BakeInOven     < CookingStep ; end

  class Chain          < Stage
    collection     :stages, Stage
    collects       Chain, :stage
    collects       MixContents,    :stage
    collects       BakeInOven,     :stage

    def add_to_container(ctr_name, ingredients, &block)
      stage(:add_to_container, {:owner => self}, :factory => AddToContainer) do
        container Kitchen.utensil(ctr_name)
        ingredients.each do |ing|
          contents << Kitchen.ingredient(ing)
        end
      end
    end
  end

  class Workflow < Chain
  end

  extend Gorillib::Collection::HasCollection
  has_collection(:workflow, Workflow)

  workflow :cherry_pie do
    utensil :large_bowl
    utensil :rolling_pin
    utensil :pie_tin
    utensil :cutting_board
    utensil :saucepan
    utensil :stove
    utensil :oven
    utensil :wire_rack

    chain :crust do
      p [self, self.owner]
      ingredient :flour,     :qty => '3 cups'
      ingredient :sugar,     :qty => '2 tbsp'
      ingredient :salt,      :qty => '1.5 tsp'
      ingredient :butter,    :qty => '0.5 cups'
      ingredient :buttermilk,:qty => '0.5 cups'

      add_to_container :large_bowl, [:flour, :sugar, :salt]
      # mix
      # combine previous, :butter, :shortening
      # mix     :until => 'resembles coarse crumbs'
      # combine previous, :buttermilk
      # mix     :until => 'resembles pastry'
      # split   previous, :into => [:ball_1, :ball_2]
      # refrigerate(wrap(:ball_1))
      # refrigerate(wrap(:ball_2))
    end

    chain :filling do
      ingredient :cherries,  :qty => '4 cups'
      ingredient :cornstarch,:qty => '1/3 cup'
      ingredient :sugar2,     :qty => '1.5 cups'
      ingredient :salt2,      :qty => '1 dash'
      ingredient :butter2,    :qty => '2 tbsp'

      # drain :cherries, :into => ingredient(:cherry_juice, :qty => '1/2 cup')

    end
  end
end
