require 'cornflower/walker'

module Cornflower
  module Export
    class PlanUMLExporter < Cornflower::Walker::Handler
      attr_accessor :indent, :default_line_shape, :default_line_style, :default_node_shape, :default_node_style

      def initialize(out)
        @default_node_shape = "node"
        @default_node_style = nil
        @default_line_shape = "-->"
        @default_line_style = nil
        @indent = 2
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
        shape = c.attributes.fetch(:shape, @default_node_shape)
        node_style = c.attributes.fetch(:style, @default_node_style)
        style = node_style ? " ##{node_style}" : ""
        @out << "#{indent_space(level)}#{shape} #{c.name}#{style}#{scope}\n"
      end

      def on_end_node(c, level)
        if !c.children.empty?
          @out << "#{indent_space(level)}}\n"
        end
      end

      def on_relation(r)
        line_shape = r.attributes.fetch(:shape, @default_line_shape)
        line_style = r.attributes.fetch(:style, @default_line_style)
        style = line_style ? " ##{line_style}" : ""
        description = r.has_description? ? " : #{r.description}" : ""
        @out << "#{r.from.name} #{line_shape} #{r.to.name}#{style}#{description}\n"
      end

      private

      def indent_space(level)
        " " * @indent * level
      end

    end
  end
end
