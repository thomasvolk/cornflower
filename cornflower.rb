module Cornflower
  class Relation
    attr_reader :from, :to

    def initialize(from, to)
      @from = from
      @to = to
      @description = nil
    end

    def |(description)
      @description = description
    end

    def to_s
      d = ""
      if !@description.nil?
        d = " | #{@description}"
      end
      "Relation(#{@from} --> #{@to}#{d})"
    end
  end

  class Context
    attr_reader :relations

    def initialize
      @relations = []
      connect_lr = lambda { |context| Proc.new { |component| context.relation(self, component) } }
      connect_rl = lambda { |context| Proc.new { |component| context.relation(component, self) } }
      @class_extension = Module.new
      @class_extension.define_method(:>>, connect_lr.call(self))
      @class_extension.define_method(:<<, connect_rl.call(self))
      @class_extension.define_method(:submodules) {
        self.constants.map { |name| self.const_get name }.filter { |c| c.is_a? Module }
      }
    end

    def register(*components)
      components.each { |c|
        c.extend(@class_extension)
        register(*c.submodules)
      }
    end

    def relation(from, to)
      r = Relation.new(from, to)
      @relations << r
      r
    end

    def to_s
      "Context(relations=#{self.relations.map {|r| r.to_s}})"
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

context = Cornflower::Context.new

context.register(AWS)

OnlineShop >> ShopDatabase
ProductCatalogService >> ProductDatabase
OnlineShop >> ProductCatalogService
OnlineShop >> OrderQueue | 'send order event'
OrderQueue << WarehouseService | 'receive order event'

puts context.to_s
