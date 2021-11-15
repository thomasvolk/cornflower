module Cornflower
  module Export
    class PlanUMLExporter
        attr_accessor :default_shape, :indent, :default_line
  
        def initialize(out)
          @default_shape = "node"
          @indent = 2
          @default_line = "-->"
          @out = out
        end
  
        def on_start
          @out << "@startuml\n\n"        
        end

        def on_finish
          @out << "\n@enduml\n"        
        end

        def on_begin_node(c, level)
          scope = ""
          if !c.children.empty?
            scope = " {"
          end
          shape = c.attributes.fetch(:shape, @default_shape)
          @out << "#{indent_space(level)}#{shape} #{c.name}#{scope}\n"
        end
  
        def on_end_node(c, level)
          if !c.children.empty?
            @out << "#{indent_space(level)}}\n"
          end
        end
  
        def on_relation(r)
          line = r.attributes.fetch(:line, @default_line)
          description = r.has_description? ? " : #{r.description}" : ""
          @out << "#{r.from.name} #{line} #{r.to.name}#{description}\n"
        end
  
        private
  
        def indent_space(level)
          " " * @indent * level
        end
  
    end
  end
end