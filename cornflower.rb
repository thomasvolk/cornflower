
module Cornflower
    module ClassExtensions
        def invokes(component)
            puts "#{self} ---> #{component}"
        end
    end
    class Context
        def initialize(*components)
            def newInvokeMethod(context)
                Proc.new { |component| puts "[#{context}] #{self} ---> #{component}" }
            end
            @classExtension = Module.new
            @classExtension.define_method(:invokes, newInvokeMethod(self))
            initComponents(components)
        end
        def initComponents(components)
            components.filter { |c| c.is_a? Module }.each { |c|
                initComponent(c)
            }
        end
        def initComponent(component)
            component.extend(@classExtension)
            components = component.constants.map { |name| component.const_get(name) }
            initComponents(components)
        end
        def init(&block)
            block.call()
        end
        private :initComponents, :initComponent
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

ctx = Context.new(AWS)

ctx.init {
    OnlineShop .invokes ShopDatabase
    ProductCatalogService .invokes ProductDatabase
    OnlineShop .invokes ProductCatalogService
    OnlineShop .invokes OrderQueue
    WarehouseService .invokes OrderQueue
}
