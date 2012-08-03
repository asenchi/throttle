# Throttle

Throttle allows you to rate limit based on a number of strategies.
Currently two strategies are implemented, 'interval' and 'timespan'.
Using an 'interval' you could limit the number of requests you receive
and using a 'timespan' you can set a max around hourly and daily
settings (planned for the future to be configurable).

## Installation

Add this line to your application's Gemfile:

    gem 'throttle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install throttle

## Usage

Example of default setup (connects to Redis localhost):

```ruby
Throttle.setup
```

Example of connecting to an external Redis

```ruby
Throttle.setup(Redis.new(...))
```

Example of working with the default limits set above (only one default
limit can be specified, either timespan or interval:

```ruby
Throttle.limited?(:default)
```

Example of a timespan strategy (required keys: max, timespan):

```ruby
Throttle.set_limit(:apihits, {:max => 1000, :timespan => "daily"})
```

Example of interval strategy (required keys: interval):

```ruby
Throttle.set_limit(:apirate, {:interval => 3.0})
```

Example of a temporary interval strategy using blocks (not currently implemented):

```ruby
Throttle.set_limit(:apirate, {:interval => 3.0}) do
  # do work
end
```

Example of checking whether we are limited:

```ruby
Throttle.limited?(:apihits)
Throttle.limited?(:apirate)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
