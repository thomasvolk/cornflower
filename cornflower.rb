module Cornflower

  def self.context(*components)
    Context.new(*components)
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
    attr_reader :relations, :components

    def initialize(*components)
      @relations = []
      connect_lr = lambda { |context| Proc.new { |component| context.relation(self, component) } }
      connect_rl = lambda { |context| Proc.new { |component| context.relation(component, self) } }
      @class_extension = Module.new
      @class_extension.define_method(:>>, connect_lr.call(self))
      @class_extension.define_method(:<<, connect_rl.call(self))
      @class_extension.define_method(:submodules) {
        self.constants.map { |name| self.const_get name }.filter { |c| c.is_a? Module }
      }
      @class_extension.define_method(:submodules?) { !self.submodules.empty? }
      @class_extension.define_method(:basename) { self.name.split('::').last }
      @class_extension.define_method(:get) { |name, default|
        self.class_variable_defined?(name) ? self.class_variable_get(name) : default
      }
      @class_extension.define_method(:component_name) { self.get(:@@name, self.basename) }
      @components = components
      register(*components)
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
      traverse_components(filter, 0, @context.components)
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


#-------------------------------


class AWS
  @@shape = "cloud"

  class Kubernetes

    class OnlineShop
      @@tags = [:dev, :shop]
      @@shape = "hexagon"
    end

    class ProductCatalogService
      @@tags = [:dev]
      @@shape = "hexagon"
    end

    class WarehouseService
      @@tags = [:dev]
      @@shape = "hexagon"
    end
  end

  class OrderQueue
    @@tags = [:dev]
    @@name = "order_queue"
    @@shape = "queue"
  end

  class ShopDatabase
    @@tags = [:dev, :shop]
    @@shape = "database"
  end

  class ProductDatabase
    @@tags = [:dev]
    @@shape = "database"
  end

end

context = Cornflower::context(AWS)

AWS::Kubernetes::OnlineShop >> AWS::ShopDatabase
AWS::Kubernetes::ProductCatalogService >> AWS::ProductDatabase
AWS::Kubernetes::OnlineShop >> AWS::Kubernetes::ProductCatalogService
AWS::Kubernetes::OnlineShop >> AWS::OrderQueue | 'send order event'
AWS::OrderQueue << AWS::Kubernetes::WarehouseService | 'receive order event'

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

plantuml = PlanUMLExporter.new

walker = context.walker
walker.on_begin_component {|c, l| plantuml.begin_component(c, l) }
walker.on_end_component {|c, l| plantuml.end_component(c, l) }
walker.on_relation {|r| plantuml.relation(r) }

puts "@startuml"

def tag_filter(*tags)
  ->(c) { !c.get(:@@tags, []).filter {|t| tags.include? t }.empty? }
end

walker.walk(tag_filter(:dev))

puts "@enduml"
