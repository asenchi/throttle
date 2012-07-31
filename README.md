# Throttle

TODO: Write a gem description

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
Throttle.create_limit(:apihits, {:max => 1000, :timespan => 86400})
```

Example of interval strategy (required keys: interval):

```ruby
Throttle.create_limit(:apirate, {:interval => 3.0})
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
