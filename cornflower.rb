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

    def walk
      traverse_components(0, @context.components)
      @context.relations.each { |r| @on_relation.call(r) }
    end

    private
    
    def traverse_components(level, components)
      components.each { |c|
        @on_begin_component.call(c, level)
        traverse_components(level + 1, c.submodules)
        @on_end_component.call(c, level)
      }
    end

  end
end


#-------------------------------


module AWS

  module Kubernetes
    class OnlineShop
    end

    class ProductCatalogService
    end

    class WarehouseService
    end
  end

  module OrderQueue
  end

  class ShopDatabase
  end

  class ProductDatabase
  end

end

include AWS::Kubernetes
include AWS

context = Cornflower::context(AWS)

OnlineShop >> ShopDatabase
ProductCatalogService >> ProductDatabase
OnlineShop >> ProductCatalogService
OnlineShop >> OrderQueue | 'send order event'
OrderQueue << WarehouseService | 'receive order event'

walker = context.walker
walker.on_begin_component {|c, level|
  scope = ""
  if c.submodules?
    scope = " {"
  end
  ls = "  " * level
  puts "#{ls}node #{c.basename}#{scope}"
}
walker.on_end_component {|c, level|
  if c.submodules?
    ls = "  " * level
    puts "#{ls}}"
  end
}
walker.on_relation {|r|
  puts "#{r.from.basename} -> #{r.to.basename}"
}

puts "@startuml"

walker.walk


puts "@enduml"
