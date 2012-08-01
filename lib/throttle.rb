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
  # id  = unique identifier (default: nil)
  # t   = specified time to test against (default: nil)
  #
  # Examples
  #
  #   Throttle.limited?(:test)
  #   # => true
  #
  # Returns true or false
  def limited?(sym, id=nil, t=nil)
    start = t ? convert(t) : Time.now.utc.to_i

    if id
      key = [sym.to_s, id].join(":")
    else
      key = sym.to_s
    end

    c = config[sym.to_s]
    case c[:strategy]
    when "interval"
      last = cache_get(key) rescue nil
      allowed = !last || (start - last.to_i) >= c[:interval]
      begin
        cache_set(key, start)
        allowed
      rescue => e
        # If we get an error, don't block unnecessarily
        allowed = true
      end
    when "timespan"
      case c[:timespan]
      when :hourly
        seconds = 3600
        display = "%Y-%m-%dT%H"
      when :daily
        seconds = 86400
        display = "%Y-%m-%d"

      end
      window = Time.at(start - seconds).strftime(display)
      timekey = [key, window].join(':')
      if count = (cache_has?(timekey).to_i + 1 rescue 1)
        allowed = count <= seconds
      end
    end
  end

  # Public: Create a new limit
  #
  # sym      = Identify this limit
  # manifest = Hash that provides an interval or timespan
  #            configuration
  # blk      = Pass a block (thus creating a temporary limit)
  #
  # Examples
  #
  #   Throttle.set_limit(:apihits, {:max => 1000, :timespan => 86400})
  #   # =>
  #   Throttle.set_limit(:apirate, {:interval => 3.0})
  #   # =>
  #
  # Returns 
  def set_limit(sym, manifest, &blk)
    prefix = sym.to_s
    case
    when manifest.has_key?(:interval)
      manifest.delete_if {|k| k != :interval }
      manifest[:strategy] = "interval"
    when manifest.has_key?(:timespan)
      manifest.delete_if {|k| k !~ /(timespan|max)/ }
      manifest[:strategy] = "timespan"
    end

    config[prefix] = manifest
    # Warm up the cache
    cache_set(prefix, 0)
  end

  # Public: Configuration
  #
  # Returns a hash with the limit configuration
  def config
    @config ||= {}
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
  # Returns an Hash of limits
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
    @config = {}
  end
end
