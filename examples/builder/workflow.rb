module WukongTest

  class WorkflowBuilder
    include Gorillib::FancyBuilder
  end

  class Utensil
    include Gorillib::FancyBuilder
    field           :size,    String
  end

  class Ingredient
    include Gorillib::FancyBuilder
    field           :qty,  Integer
  end


  class Kitchen
    extend Gorillib::Collection::HasCollection
    has_collection :utensils,    Utensil
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

    def ingredient(*args, &block) ; Kitchen.ingredient(*args, &block) ; end
  end

  class CookingStep    < Stage ; end

  class AddToContainer < CookingStep
    collection     :contents, Ingredient
  end
  class MixContents    < CookingStep ; end
  class BakeInOven     < CookingStep ; end

  class Chain          < Stage
    collection     :stages, Stage
    collects       Chain, :stage
    collects       AddToContainer, :stage
    collects       MixContents,    :stage
    collects       BakeInOven,     :stage
  end

  class Workflow < Chain
  end

  extend Gorillib::Collection::HasCollection
  has_collection(:workflow, Workflow)

  workflow(:make_pie) do
    chain(:make_crust) do
      utensil(:mixing_bowl, :size => '6 in')
      utensil(:whisk)

      eggs = ingredient(:eggs, :qty => 2)
      add_to_container  :raw_items, :contents => { :eggs => eggs }
    end
  end
end
