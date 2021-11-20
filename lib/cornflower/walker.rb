module Cornflower
  class Walker
    class Handler
      def on_config(config)
        config.each do | name, value |
          if self.respond_to?(name)
            self.send("#{name}=", value)
          end
        end
      end

      def on_start
      end

      def on_finish
      end

      def on_begin_node(c, level)
      end

      def on_end_node(c, level)
      end

      def on_relation(r)
      end
    end
    attr_accessor :filter

    def initialize(model)
      @model = model
      @filter = ->(c) {true}
    end

    def walk(handler)
      handler.on_config(@model.config)
      handler.on_start
      traverse_nodes(handler, 0, @model.children)
      @model.relations.each { |r|
        if @filter.call(r.from) && @filter.call(r.to)
          handler.on_relation(r)
        end
      }
      handler.on_finish
    end

    private

    def traverse_nodes(handler, level, nodes)
      nodes.each { |n|
        filter_match = @filter.call(n)
        new_level = level
        if filter_match
          new_level = new_level + 1
          handler.on_begin_node(n, level)
        end
        traverse_nodes(handler, new_level, n.children)
        if filter_match
          handler.on_end_node(n, level)
        end
      }
    end

  end
end