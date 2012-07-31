require_relative "test_helper"

class TestThrottle < Test::Unit::TestCase
  def setup
    Throttle.mock!
    Throttle.setup
  end

  def teardown
    Throttle.reset!
  end

  def test_mocking
    assert Throttle.mocking?
  end

  def test_default_setup
    assert_not_nil Throttle.cache
  end

  def test_create_limit
    Throttle.create_limit(:test, {:interval => 9000})
    assert Throttle.limits.has_key?("test")
  end

  def test_limit_value
    Throttle.create_limit(:test, {:interval => 9000})
    assert_equal Throttle.limits["test"], "interval:9000"
  end
end
