require 'test_helper'
require 'minitest/autorun'
require 'model'
require 'cornflower'
require 'cornflower/filter'
require 'cornflower/walker'
require 'cornflower/export/plantuml'

class PlantUmlExportTest < Minitest::Test

  def test_all
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

  def test_include_tag_dev
    s = StringIO.new
    plantuml = Cornflower::Export::PlanUMLExporter.new s
    walker = Cornflower::Walker.new TestModel::MODEL
    walker.filter = Cornflower::Filter::tags([:dev])
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
OnlineShop --> order_queue : push order
WarehouseService ..> order_queue #line:red;line.bold;text:red : pull order

@enduml
""", s.string
  end

  def test_include_tag_shop
    s = StringIO.new
    plantuml = Cornflower::Export::PlanUMLExporter.new s
    walker = Cornflower::Walker.new TestModel::MODEL
    walker.filter = Cornflower::Filter::tags([:shop])
    walker.walk plantuml

    assert_equal """@startuml

hexagon OnlineShop
database ShopDatabase
OnlineShop --> ShopDatabase

@enduml
""", s.string
  end

  def test_exclude_tag_catalog
    s = StringIO.new
    plantuml = Cornflower::Export::PlanUMLExporter.new s
    walker = Cornflower::Walker.new TestModel::MODEL
    walker.filter = Cornflower::Filter::tags([:catalog], true)
    walker.walk plantuml

    assert_equal """@startuml

cloud CloudProvider #aliceblue;line:blue;line.dotted;text:blue {
  frame Kubernetes {
    hexagon OnlineShop
    hexagon WarehouseService
  }
  queue order_queue
  database ShopDatabase
  database ProductDatabase
}
OnlineShop --> ShopDatabase
OnlineShop --> order_queue : push order
WarehouseService ..> order_queue #line:red;line.bold;text:red : pull order

@enduml
""", s.string
  end

end
