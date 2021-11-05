module Cornflower

  module Filter
    def self.tags(*tags)
      ->(c) { !c.get(:@@tags, []).filter {|t| tags.include? t }.empty? }
    end
  end

  def self.register(root)
    Context.new(root)
  end

  class Relation
    attr_reader :from, :to

    def initialize(from, to)
      @from = from
      @to = to
      @description = nil
    end

    def |(description)
      @description = description
      self
    end

    def to_s
      d = ""
      unless @description.nil?
        d = " | #{@description}"
      end
      "Relation(#{@from} --> #{@to}#{d})"
    end
  end

  class Context
    attr_reader :relations, :root

    def initialize(root)
      @relations = []
      @class_extension = Module.new
      connect_lr = lambda { |context| Proc.new { |component| context.relation(self, component) } }
      connect_rl = lambda { |context| Proc.new { |component| context.relation(component, self) } }
      @class_extension.define_method(:>>, connect_lr.call(self))
      @class_extension.define_method(:<<, connect_rl.call(self))
      @class_extension.define_method(:submodules) {
        self.constants.map { |name| self.const_get name }.filter { |c| c.is_a? Module }.sort { |a,b| a.name <=> b.name }
      }
      @class_extension.define_method(:submodules?) { !self.submodules.empty? }
      @class_extension.define_method(:basename) { self.name.split('::').last }
      @class_extension.define_method(:get) { |name, default|
        self.class_variable_defined?(name) ? self.class_variable_get(name) : default
      }
      @class_extension.define_method(:component_name) { self.get(:@@name, self.basename) }

      @root = root
      root_class_extension = Module.new
      return_context = lambda { |context| Proc.new {context} }
      root_class_extension.define_method(:context, return_context.call(self))
      @root.extend(root_class_extension)
      register(@root)
    end

    def relation(from, to)
      r = Relation.new(from, to)
      @relations << r
      r
    end

    def walker
      ContextWalker.new self
    end

    def to_s
      "Context(relations=#{self.relations.map {|r| r.to_s}})"
    end

    private

    def register(*components)
      components.each { |c|
        c.extend(@class_extension)
        register(*c.submodules)
      }
    end

  end

  class ContextWalker
    def initialize(context)
      @context = context
      @on_begin_component = proc {|c| }
      @on_end_component = proc {|c| }
      @on_relation = proc {|r| }
    end

    def on_begin_component(&block)
      @on_begin_component = block
    end

    def on_end_component(&block)
      @on_end_component = block
    end

    def on_relation(&block)
      @on_relation = block
    end

    def walk(filter = ->(c) {true})
      traverse_components(filter, 0, [@context.root])
      @context.relations.each { |r|
        if filter.call(r.from) && filter.call(r.to)
          @on_relation.call(r)
        end
      }
    end

    private

    def traverse_components(filter, level, components)
      components.each { |c|
        filter_match = filter.call(c)
        new_level = level
        if filter_match
          new_level = new_level + 1
          @on_begin_component.call(c, level)
        end
        traverse_components(filter, new_level, c.submodules)
        if filter_match
          @on_end_component.call(c, level)
        end
      }
    end

  end
end
