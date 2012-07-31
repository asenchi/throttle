require "throttle/version"

module Throttle
  extend self

  def setup(cache=nil, options={})
    perform_setup(cache, options)
  end

  def limited?(sym, t=nil)
    @start = t ? convert(t) : Time.now.utc.to_i
  end

  def create_limit(sym, manifest)
    @prefix = sym.to_s
    if manifest.has_key?(:interval)
      @strategy = "interval"
      @interval = manifest[:interval].to_f
    else
      @strategy = "timespan"
      @max      = manifest[:max]
      @timespan = manifest[:timespan]
    end
  end

  def cache
    @cache
  end

  private

  def convert(time)
    time.to_i
  end

  def perform_setup(cache, options)
    @cache = cache ? cache : Redis.new
    @options = options
    create_default_limit(@options)
  end

  def create_default_limit(options)
    return if options.empty?

    if options.keys.include?(:interval)
      options.delete_if {|k| k != :interval }
      create_limit(:default, options)
    end

    if options[:timespan] && options[:max]
      options.delete_if {|k| k !~ /(timespan|max)/ }
      create_limit(:default, options)
    end
  end
end
