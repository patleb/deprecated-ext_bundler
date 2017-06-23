$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ext_bundler/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ext_bundler"
  s.version     = ExtBundler::VERSION
  s.authors     = ["Patrice Lebel"]
  s.email       = ["patleb@users.noreply.github.com"]
  s.homepage    = "https://github.com/patleb/ext_bundler"
  s.summary     = "ExtBundler"
  s.description = "ExtBundler"
  s.license     = "MIT"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "README.md"]

  s.add_dependency 'bundler'
  s.add_dependency 'gem-path', '~> 0.6'
end
