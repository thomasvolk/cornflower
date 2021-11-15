require 'test_helper'
require 'minitest/autorun'
require 'cornflower/filter'
require 'model'

class FilterTest < Minitest::Test

  def test_tags_filter
    filter = Cornflower::Filter::tags()
    assert_equal true, filter.call(TestModel::MODEL.children[0])
    filter = Cornflower::Filter::tags(:not_found)
    assert_equal false, filter.call(TestModel::MODEL.children[0])
  end

end
