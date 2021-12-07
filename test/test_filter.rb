require 'test_helper'
require 'minitest/autorun'
require 'cornflower/filter'
require 'model'

class FilterTest < Minitest::Test

  def test_abstract_filter
    assert_raises "not implemented" do
      Cornflower::Filter::AbstractFilter.new().filter(nil)
    end
  end

  def test_tags_filter
    filter = Cornflower::Filter::tags []
    assert_equal false, filter.filter(TestModel::MODEL.children[0])
    filter = Cornflower::Filter::tags [:not_found]
    assert_equal false, filter.filter(TestModel::MODEL.children[0])
    filter = Cornflower::Filter::tags [:cloud]
    assert_equal true, filter.filter(TestModel::MODEL.children[0])
    filter = Cornflower::Filter::tags([:cloud], invert=true)
    assert_equal false, filter.filter(TestModel::MODEL.children[0])
  end

  def test_pass_trough_filter
    node = TestModel::MODEL.children[0]
    filter = Cornflower::Filter::PassThroughFilter.new
    assert_equal true, filter.filter(node)
    assert_equal true, filter.filter(nil)
  end

  def test_stop_filter
    node = TestModel::MODEL.children[0]
    filter = Cornflower::Filter::StopFilter.new
    assert_equal false, filter.filter(node)
    assert_equal false, filter.filter(nil)
  end

  def test_filter_chain
    node = TestModel::MODEL.children[0]
    stop_filter = Cornflower::Filter::StopFilter.new
    pass_trough_filter = Cornflower::Filter::PassThroughFilter.new
    
    filter = Cornflower::Filter::FilterChain.new([pass_trough_filter, stop_filter])
    assert_equal false, filter.filter(node)

    filter = Cornflower::Filter::FilterChain.new([pass_trough_filter, pass_trough_filter])
    assert_equal true, filter.filter(node)
  end

end
