require 'minitest/autorun'
require 'model'
require 'cornflower'


class CornflowerTest < Minitest::Test
  include TestModel

  def test_model
    context = TestModel::context
  end

end
