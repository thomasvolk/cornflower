require_relative 'lib/cornflower/version'

Gem::Specification.new do |s|
  s.name         = 'cornflower'
  s.version      = Cornflower::VERSION
  s.summary      = "Cornflower"
  s.description  = "A simple ruby dsl for generation diagrams"
  s.authors      = ["Thomas Volk"]
  s.email        = 'info@thomasvolk.de'
  s.homepage     = 'https://github.com/thomasvolk/cornflower.git'
  s.license      = 'Apache-2.0'
  s.files        = Dir.glob("{lib,bin}/**/*")
  s.require_path = 'lib'
  s.bindir       = 'bin'
  s.executables  = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
end
