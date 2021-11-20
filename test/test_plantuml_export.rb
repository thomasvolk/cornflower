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
    walker = Cornflower::Walker.new TestModel::MODEL
    walker.walk plantuml

    assert_equal """@startuml

cloud CloudProvider #aliceblue;line:blue;line.dotted;text:blue {
  frame Kubernetes {
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
WarehouseService ..> order_queue #line:red;line.bold;text:red : pull order

@enduml
""", s.string

  end

  def test_plantuml_with_filter
    s = StringIO.new
    plantuml = Cornflower::Export::PlanUMLExporter.new s
    walker = Cornflower::Walker.new TestModel::MODEL
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
WarehouseService ..> order_queue #line:red;line.bold;text:red : pull order

@enduml
""", s.string


  end

end
