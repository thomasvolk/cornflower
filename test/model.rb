require 'cornflower'

module TestModel

  MODEL = Cornflower::Model.new do
    CloudProvider(:shape => :cloud) {
      Kubernetes {
        OnlineShop(:shape => :hexagon, :tags => [:dev, :shop])
        ProductCatalogService(:shape => :hexagon, :tags => [:dev])
        WarehouseService(:shape => :hexagon, :tags => [:dev])
      }
      OrderQueue(:name => "order_queue", :shape => :queue, :tags => [:dev])
      ShopDatabase(:shape => :database, :tags => [:dev, :shop])
      ProductDatabase(:shape => :database, :tags => [:dev])

      Kubernetes().OnlineShop >> ShopDatabase()
      Kubernetes().ProductCatalogService >> ProductDatabase()
      Kubernetes().OnlineShop >> Kubernetes().ProductCatalogService()
    }
  end
  MODEL.add do
    CloudProvider().Kubernetes().OnlineShop >> CloudProvider().OrderQueue() | "push order"
    CloudProvider().OrderQueue() << CloudProvider().Kubernetes().WarehouseService | "pull order"
  end
  MODEL.sealed = true

end
