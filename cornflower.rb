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
      def new_connect_method(context)
        Proc.new { |component| context.relation(self, component) }
      end
      @class_extension = Module.new
      @class_extension.define_method(:>>, new_connect_method(self))
      @class_extension.define_method(:submodules) {
        self.constants.map { |name| self.const_get name }.filter { |c| c.is_a? Module }
      }
    end

    def register(*components)
      init_components(components)
    end

    def relation(from, to)
      r = Relation.new(from, to)
      @relations << r
      r
    end

    def init_components(components)
      components.each { |c|
        init_component(c)
      }
    end

    def init_component(component)
      component.extend(@class_extension)
      init_components(component.submodules)
    end

    private :init_components, :init_component
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
WarehouseService >> OrderQueue | 'receive order event'

puts context.relations.map {|r| r.to_s}
