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
        puts "#{indent_space(level)}#{shape} #{c.component_name}#{scope}"
      end

      def end_component(c, level)
        if c.submodules?
          puts "#{indent_space(level)}}"
        end
      end

      def relation(r)
        arrow = @default_arrow
        puts "#{r.from.component_name} #{arrow} #{r.to.component_name}"
      end

      private

      def indent_space(level)
        " " * @indent * level
      end
    end

  end
end
