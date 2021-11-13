require 'test_helper'
require 'minitest/autorun'
require 'model'
require 'cornflower'
require 'cornflower/export/plantuml'

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
  database ShopDatabase
  database ProductDatabase
}
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue : push order
WarehouseService --> order_queue : pull order
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
database ShopDatabase
database ProductDatabase
OnlineShop --> ShopDatabase
ProductCatalogService --> ProductDatabase
OnlineShop --> ProductCatalogService
OnlineShop --> order_queue : push order
WarehouseService --> order_queue : pull order
""", s.string


  end

end
