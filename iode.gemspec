# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iode/version'

Gem::Specification.new do |spec|
  spec.name          = "iode"
  spec.version       = Iode::VERSION
  spec.authors       = ["Chris Corbyn"]
  spec.email         = ["chris@w3style.co.uk"]
  spec.summary       = %q{An experimental lisp-family language hosted on Ruby}
  spec.description   = <<-EOF
  Iode is a work in progress real language on LLVM.
  This Ruby Gem exists solely so the author can experiment with new language
  features before committing those ideas to the real language. It is not
  intended for general use, nor is it intended to be fast or concise.
  EOF

  spec.homepage      = "https://github.com/d11wtq/iode-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "whittle", "~> 0.0.8"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
