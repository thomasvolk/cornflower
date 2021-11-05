require 'minitest/autorun'
require 'model'
require 'cornflower'
require 'export/plantuml'

class PlantUmlExportTest < Minitest::Test

  def test_plantuml
    context = TestModel::context

    plantuml = Cornflower::Export::PlanUMLExporter.new

    s = StringIO.new

    plantuml.export(context, s)

    assert_equal s.string, """cloud CloudProvider {
  queue order_queue
  node Kubernetes {
    hexagon ProductCatalogService
    hexagon OnlineShop
    hexagon WarehouseService
  }
  database ShopDatabase
  database ProductDatabase
}
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue
WarehouseService --> order_queue
"""

  end

  def test_plantuml_with_filter

    context = TestModel::context

    plantuml = Cornflower::Export::PlanUMLExporter.new

    s = StringIO.new

    plantuml.export(context, s, Cornflower::Filter::tags(:dev))

    assert_equal s.string, """queue order_queue
hexagon ProductCatalogService
hexagon OnlineShop
hexagon WarehouseService
database ShopDatabase
database ProductDatabase
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue
WarehouseService --> order_queue
"""


  end

end
