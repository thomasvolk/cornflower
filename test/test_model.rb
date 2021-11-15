require 'test_helper'
require 'minitest/autorun'
require 'cornflower'

class ModelTest < Minitest::Test

  def test_sealed_nodes
    model = Cornflower::Model.new do
      A do
        B do
        end
      end
    end

    assert_equal :X, model.X.name
    
    model.sealed = true
    assert_raises NoMethodError do
      model.not_existing
    end
    
    assert_equal :A, model.A.name
    assert_raises NoMethodError do
      model.A.B.not_existing
    end

    model.sealed = false
    assert_equal :not_existing, model.A.not_existing.name
    
  end

end
