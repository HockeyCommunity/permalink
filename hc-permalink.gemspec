# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hc/permalink/version"

Gem::Specification.new do |spec|
  spec.name          = "hc-permalink"
  spec.version       = HC::Permalink::VERSION
  spec.authors       = ["Jack Hayter"]
  spec.email         = ["jack@hockey-community.com"]

  spec.summary       = "Generates URL friendly (and unique) strings of latin characters for use as permalinks"
  spec.description   = "Transliterates characters into Latin character set and allows for generation of uniuqe variants with an incrementing ID"
  spec.homepage      = "https://github.com/HockeyCommunity/permalink"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "russian"
  spec.add_development_dependency "activesupport"
end
