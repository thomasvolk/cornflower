require 'cornflower'

module TestModel

  MODEL = Cornflower::model("example") do
    CloudProvider(:shape => :cloud) {
      Kubernetes {
        OnlineShop(:shape => hexagon, :tags => [:dev, :shop])
        ProductCatalogService(:shape => :hexagon, :tags => [:dev])
        WarehouseService(:shape => :hexagon, :tags => [:dev])
      }
      OrderQueue(:name => "order_queue", :shape => :queue, :tags => [:dev])
      ShopDatabase(:shape => :database, :tags => [:dev, :shop])
      ProductDatabase(:shape => :database, :tags => [:dev])

      Kubernetes().OnlineShop >> ShopDatabase()
      Kubernetes().ProductCatalogService >> ProductDatabase()
      Kubernetes().OnlineShop >> Kubernetes().ProductCatalogService()
      Kubernetes().OnlineShop >> OrderQueue()
      OrderQueue() << Kubernetes().WarehouseService
    }
  end

end
