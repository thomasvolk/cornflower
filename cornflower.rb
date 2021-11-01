module Cornflower
  class Context
    def initialize(*components, &init_block)
      def new_connect_method(context)
        Proc.new { |component| puts "[#{context}] #{self} ---> #{component}" }
      end
      @class_extension = Module.new
      @class_extension.define_method(:>>, new_connect_method(self))
      init_components(components)
      init_block.call()
    end

    def init_components(components)
      components.filter { |c| c.is_a? Module }.each { |c|
        init_component(c)
      }
    end

    def init_component(component)
      component.extend(@class_extension)
      components = component.constants.map { |name| component.const_get(name) }
      init_components(components)
    end
    private :init_components, :init_component
  end
end


#-------------------------------

include Cornflower

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

ctx = Context.new(AWS) {
  OnlineShop >> ShopDatabase
  ProductCatalogService >> ProductDatabase
  OnlineShop >> ProductCatalogService
  OnlineShop >> OrderQueue
  WarehouseService >> OrderQueue
}
