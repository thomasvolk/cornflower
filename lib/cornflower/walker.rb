module Cornflower
  module Walker
    class NodeWalker
      attr_accessor :filter

      def initialize(model)
        @model = model
        @filter = ->(c) {true}
      end

      def walk(exporter)
        exporter.on_start
        traverse_nodes(exporter, 0, @model.children)
        @model.relations.each { |r|
          if @filter.call(r.from) && @filter.call(r.to)
            exporter.on_relation(r)
          end
        }
        exporter.on_finish
      end

      private

      def traverse_nodes(exporter, level, nodes)
        nodes.each { |n|
            filter_match = @filter.call(n)
            new_level = level
            if filter_match
              new_level = new_level + 1
              exporter.on_begin_node(n, level)
            end
            traverse_nodes(exporter, new_level, n.children)
            if filter_match
              exporter.on_end_node(n, level)
            end
          }
        end

    end
  end
end