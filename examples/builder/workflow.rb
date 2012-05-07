module WukongTest

  def self.workflow(name=nil, attrs={}, &block)
    @workflow ||= Workflow.new(attrs.merge(:name => name))
    @workflow.instance_exec(&block) if block
    @workflow
  end

  class WorkflowBuilder
    include Gorillib::FancyBuilder
    field           :name,        Symbol
  end

  class Stage          < WorkflowBuilder
    field          :input,   String
    field          :output,  String
    member         :from,    Stage
    member         :to,      Stage
  end

  class Chain          < Stage
    collection     :stages, Stage

    def chain(chain_name)
      # TODO: make a stage with a more specific Factory
      ch = stages(chain_name, :factory => Chain)
    end
  end

  class Workflow < Chain
  end


  workflow(:make_pie) do

  end
end
