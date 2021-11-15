require 'cornflower'

module TestModel

  MODEL = Cornflower::Model.new do
    CloudProvider {
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
    CloudProvider(:shape => :cloud) do
      Kubernetes().OnlineShop >> OrderQueue() | "push order"
      OrderQueue() <<  Kubernetes().WarehouseService | "pull order" < {:line => '..>'}
    end
  end
  MODEL.sealed = true

end
