module Cornflower
  module Export
    class PlanUMLExporter
        attr_accessor :default_shape, :indent, :default_arrow
  
        def initialize
          @default_shape = "node"
          @indent = 2
          @default_arrow = "-->"
        end
  
        def begin_component(c, level)
          scope = ""
          if !c.children.empty?
            scope = " {"
          end
          shape = c.attributes.fetch(:shape, @default_shape)
          "#{indent_space(level)}#{shape} #{c.name}#{scope}\n"
        end
  
        def end_component(c, level)
          if !c.children.empty?
            return "#{indent_space(level)}}\n"
          end
        end
  
        def relation(r)
          arrow = @default_arrow
          description = r.has_description? ? " : #{r.description}" : ""
          "#{r.from.name} #{arrow} #{r.to.name}#{description}\n"
        end
  
        def export(model, out, filter = ->(c){true})
          out << "@startuml\n\n"
          walker = model.walker
          walker.on_begin_node {|c, l| out << self.begin_component(c, l) }
          walker.on_end_node {|c, l| out << self.end_component(c, l) }
          walker.on_relation {|r| out << self.relation(r) }
          walker.walk filter
          out << "\n@enduml\n"
          
        end
  
        private
  
        def indent_space(level)
          " " * @indent * level
        end
  
    end
  end
end