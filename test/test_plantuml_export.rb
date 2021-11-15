require 'test_helper'
require 'minitest/autorun'
require 'model'
require 'cornflower'
require 'cornflower/filter'
require 'cornflower/walker'
require 'cornflower/export/plantuml'

class PlantUmlExportTest < Minitest::Test

  def test_plantuml
    s = StringIO.new
    plantuml = Cornflower::Export::PlanUMLExporter.new s
    walker = Cornflower::Walker::NodeWalker.new TestModel::MODEL
    walker.walk plantuml

    assert_equal """@startuml

cloud CloudProvider {
  node Kubernetes {
    hexagon OnlineShop
    hexagon ProductCatalogService
    hexagon WarehouseService
  }
  queue order_queue
  database ShopDatabase
  database ProductDatabase
}
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue : push order
WarehouseService --> order_queue : pull order

@enduml
""", s.string

  end

  def test_plantuml_with_filter
    s = StringIO.new
    plantuml = Cornflower::Export::PlanUMLExporter.new s
    walker = Cornflower::Walker::NodeWalker.new TestModel::MODEL
    walker.filter = Cornflower::Filter::tags(:dev)
    walker.walk plantuml

    assert_equal """@startuml

hexagon OnlineShop
hexagon ProductCatalogService
hexagon WarehouseService
queue order_queue
database ShopDatabase
database ProductDatabase
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue : push order
WarehouseService --> order_queue : pull order

@enduml
""", s.string


  end

end
