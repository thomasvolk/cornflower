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
        if c.submodules?
          scope = " {"
        end
        shape = c.get(:@@shape, @default_shape)
        "#{indent_space(level)}#{shape} #{c.component_name}#{scope}\n"
      end

      def end_component(c, level)
        if c.submodules?
          return "#{indent_space(level)}}\n"
        end
      end

      def relation(r)
        arrow = @default_arrow
        "#{r.from.component_name} #{arrow} #{r.to.component_name}\n"
      end

      def export(root, out, filter = ->(c){true})
        walker = root.context.walker
        walker.on_begin_component {|c, l| out << self.begin_component(c, l) }
        walker.on_end_component {|c, l| out << self.end_component(c, l) }
        walker.on_relation {|r| out << self.relation(r) }
        walker.walk filter
      end

      private

      def indent_space(level)
        " " * @indent * level
      end

    end

  end
end
