# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sexy_content_editable/version'

Gem::Specification.new do |spec|
  spec.name          = "sexy-content-editable"
  spec.version       = SexyContentEditable::VERSION
  spec.authors       = ["Trabe Soluciones"]
  spec.email         = ["contact@trabesoluciones.com"]
  spec.summary       = %q{Sexy content editable for Rails forms}
  spec.description   = %q{Sexy content editable for Rails forms}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['{lib,app}/**/*', 'LICENSE.txt', 'README.md'] 
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-nav", "~> 0.2.4"
end
