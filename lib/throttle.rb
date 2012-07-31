require "throttle/version"

module Throttle
  extend self

  # Public: Setup our cache (Redis by default).
  #
  # cache   = the key/value implementation that responds to #get/#set (default: Redis)
  #
  # Examples
  #
  #   Throttle.setup
  #   # =>
  #
  #   Throttle.setup(Redis.new(:host => ...,))
  #   # =>
  #
  # Returns
  def setup(cache=nil, options={})
    if mocking?
      cache = limits
    end

    perform_setup(cache, options)
  end

  # Public: Test whether our limit (represented by sym) is rate
  # limited
  #
  # sym = limit identifier
  # t   = specified time to test against (default: nil)
  #
  # Examples
  #
  #   Throttle.limited?(:test)
  #   # => true
  #
  # Returns true or false
  def limited?(sym, t=nil)
    @start = t ? convert(t) : Time.now.utc.to_i
    true
  end

  # Public: Create a new limit
  #
  # sym      = Identify this limit
  # manifest = Hash that provides an interval or timespan
  #            configuration
  #
  # Examples
  #
  #   Throttle.create_limit(:apihits, {:max => 1000, :timespan => 86400})
  #
  # Returns 
  def create_limit(sym, manifest)
    prefix = sym.to_s
    if manifest.has_key?(:interval)
      strategy = "interval"
      limit = [manifest[:interval]]
    else
      strategy = "timespan"
      limit    = [manifest[:max], manifest[:timespan]]
    end

    value = "#{strategy}:#{limit.join(":")}"

    cache_set(prefix, value)
  end

  # Public: Turns on mocking mode
  #
  # Examples
  #
  #   Throttle.mock!
  #   # => true
  def mock!
    @mock = true
  end

  # Public: Checks if mocking mode is enabled
  #
  # Examples
  #
  #   Throttle.mocking?
  #   # => false
  #   Throttle.mock!
  #   Throttle.mocking?
  #   # => true
  #
  # Returns the state of mocking
  def self.mocking?
    !!@mock
  end

  # Public: Store mocked limits
  #
  # Returns an Array of limits
  def limits
    @limits ||= {}
  end

  # Public: Reset mocked data
  #
  # Examples
  #
  #   Throttle.limits
  #   # => {..}
  #   Throttle.reset!
  #   Throttle.limits
  #   # => {}
  def reset!
    @limits = {}
  end

  def cache
    @cache
  end

  protected

  # Protected: Set the value at key in cache
  #
  # Examples
  #
  #   Throttle.cache_set(key, value)
  #   # =>
  #
  # Returns
  def cache_set(key, value)
    case
    when cache.respond_to?(:[]=)
      cache[key] = value
    when cache.respond_to?(:set)
      cache.set(key, value)
    end
  end

  # Protected: Get the value at key
  #
  # Examples
  #
  #   Throttle.cache_get(key)
  #   # => value
  #
  # Returns the value
  def cache_get(key, default=nil)
    case
    when cache.respond_to?(:[])
      cache[key] || default
    when cache.respond_to?(:get)
      cache.get(key) || default
    end
  end

  # Protected: Check whether the cache contains key
  #
  # Examples
  #
  #   Throttle.cache_has?(key)
  #   # => true
  #
  # Returns true or false
  def cache_has?(key)
    case
    when cache.respond_to?(:has_key?)
      cache.has_key?(key)
    when cache.respond_to?(:get)
      cache.get(key) rescue false
    else
      false
    end
  end

  private

  def convert(time)
    time.to_i
  end

  def perform_setup(cache, options)
    @cache = cache ? cache : Redis.new
    @options = options
  end
end
