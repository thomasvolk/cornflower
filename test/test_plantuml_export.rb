require 'minitest/autorun'
require 'model'
require 'cornflower'
require 'export/plantuml'

class PlantUmlExportTest < Minitest::Test

  def test_plantuml
    plantuml = Cornflower::Export::PlanUMLExporter.new

    s = StringIO.new

    plantuml.export(TestModel::CloudProvider, s)

    assert_equal """cloud CloudProvider {
  queue order_queue
  node Kubernetes {
    hexagon WarehouseService
    hexagon ProductCatalogService
    hexagon OnlineShop
  }
  database ShopDatabase
  database ProductDatabase
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

    plantuml.export(TestModel::CloudProvider, s, Cornflower::Filter::tags(:dev))

    assert_equal """queue order_queue
hexagon WarehouseService
hexagon ProductCatalogService
hexagon OnlineShop
database ShopDatabase
database ProductDatabase
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue
WarehouseService --> order_queue
""", s.string


  end

end
