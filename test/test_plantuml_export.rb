require 'minitest/autorun'
require 'model'
require 'cornflower'
require 'export/plantuml'

class PlantUmlExportTest < Minitest::Test

  def test_plantuml
    context = TestModel::context

    plantuml = Cornflower::Export::PlanUMLExporter.new

    walker = context.walker
    walker.on_begin_component {|c, l| plantuml.begin_component(c, l) }
    walker.on_end_component {|c, l| plantuml.end_component(c, l) }
    walker.on_relation {|r| plantuml.relation(r) }


    walker.walk(Cornflower::Filter::tags(:dev))

    walker.walk

  end

end
