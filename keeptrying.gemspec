# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keeptrying/version'

Gem::Specification.new do |spec|
  spec.name          = "keeptrying"
  spec.version       = Keeptrying::VERSION
  spec.authors       = ["Jun Yokoyama"]
  spec.email         = ["jun@larus.org"]
  spec.summary       = %q{command line tool for KPT meeting.}
  spec.description   = %q{support write and read note for KPT meeting by command line.}
  spec.homepage      = "https://github.com/nysalor/keeptrying"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency "sqlite3"
  spec.add_dependency "sequel"
  spec.add_dependency "colored"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "faker"
end
