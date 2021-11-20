require 'cornflower'

module TestModel

  MODEL = Cornflower::Model.new(:default_node_shape => :frame) do
    CloudProvider(:style => "aliceblue;line:blue;line.dotted;text:blue") {
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

      ### reserved names ###

      # self
      # children
      # name
      # attributes
    }
    
    ### reserved names ###

    # self
    # children
    # sealed
    # root
    # relations
    # load
    # load_string
    # add
    # add_relation

  end

  MODEL.add do
    CloudProvider(:shape => :cloud) do
      self.Kubernetes.OnlineShop >> self.OrderQueue | "push order"
      self.OrderQueue <<  self.Kubernetes.WarehouseService | "pull order" < {:style => "line:red;line.bold;text:red", :shape => '..>'}
    end
  end
  
  MODEL.sealed = true

end
