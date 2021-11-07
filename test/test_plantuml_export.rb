require 'minitest/autorun'
require 'model'
require 'cornflower'
require 'export/plantuml'

class PlantUmlExportTest < Minitest::Test

  def test_plantuml
    plantuml = Cornflower::Export::PlanUMLExporter.new

    s = StringIO.new

    plantuml.export(TestModel::MODEL, s)

    assert_equal """cloud CloudProvider {
  node Kubernetes {
    hexagon OnlineShop
    hexagon ProductCatalogService
    hexagon WarehouseService
  }
  queue order_queue
  database ProductDatabase
  database ShopDatabase
}
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue
WarehouseService --> order_queue
""", s.string

  end

  def test_plantuml_with_filter
    plantuml = Cornflower::Export::PlanUMLExporter.new

    s = StringIO.new

    plantuml.export(TestModel::MODEL, s, Cornflower::Filter::tags(:dev))

    assert_equal """hexagon OnlineShop
hexagon ProductCatalogService
hexagon WarehouseService
queue order_queue
database ProductDatabase
database ShopDatabase
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue
WarehouseService --> order_queue
""", s.string


  end

end
