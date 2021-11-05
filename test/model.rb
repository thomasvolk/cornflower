require 'cornflower'

module TestModel

  class CloudProvider
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

  Cornflower::register(CloudProvider)

  CloudProvider::Kubernetes::OnlineShop >> CloudProvider::ShopDatabase
  CloudProvider::Kubernetes::ProductCatalogService >> CloudProvider::ProductDatabase
  CloudProvider::Kubernetes::OnlineShop >> CloudProvider::Kubernetes::ProductCatalogService
  CloudProvider::Kubernetes::OnlineShop >> CloudProvider::OrderQueue | 'send order event'
  CloudProvider::OrderQueue << CloudProvider::Kubernetes::WarehouseService | 'receive order event'
end
