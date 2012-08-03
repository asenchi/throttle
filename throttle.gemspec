# -*- encoding: utf-8 -*-
require File.expand_path('../lib/throttle/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Curt Micol"]
  gem.email         = ["asenchi@asenchi.com"]
  gem.description   = %q{Throttle something...}
  gem.summary       = %q{Throttle can be used to rate limit "something" based around interval or timespan (currently hourly or daily).}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "throttle"
  gem.require_paths = ["lib"]
  gem.version       = Throttle::VERSION
end
