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

  def test_set_limit
    Throttle.set_limit(:test, {:interval => 9000})
    assert Throttle.config.has_key?("test")
  end

  def test_limit_value
    Throttle.set_limit(:test, {:interval => 9000})
    assert_equal Throttle.config["test"], {:interval => 9000, :strategy => "interval"}
  end

  def test_interval_strategy
    Throttle.set_limit(:two, {:interval => 2.0})
    assert !Throttle.limited?(:two), "Should not be limited"
    assert Throttle.limited?(:two), "Should be limited"
    sleep 2.1
    assert !Throttle.limited?(:two), "Should not be limited a second time"
    assert Throttle.limited?(:two), "Should be limited a second time"
  end

  def test_timespan_strategy
    Throttle.set_limit(:h, {:max => 2, :timespan => "hourly"})
    assert !Throttle.limited?(:h)
    assert !Throttle.limited?(:h)
    assert Throttle.limited?(:h), "We should be limited"
  end
end
