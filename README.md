# ExtBundler

### Installation

```bash
$ gem install ext_bundler
```

### Usage

In your project Gemfile:

```ruby
# Gemfile
source 'https://rubygems.org'

if File.exist? '.ext_bundler'
  ext_bundler = File.readlines('.ext_bundler').first
else
  ext_bundler = File.join(`gem path ext_bundler`.strip, 'lib', 'ext_bundler', 'bundler.rb')
  File.write('.ext_bundler', ext_bundler)
end

load ext_bundler

# ...
```

Add `.ext_bundler` to your project .gitignore.

In some other gem's gemspec file:

```ruby
# gem_name.gemspec

# ...
Gem::Specification.new do |s|
  # ...

  s.add_dependency 'some_other_gem', github: 'account_name/repo_name'

  # ...
end
```

### Upgrading

Remove `.ext_bundler` file within your project after updating ext_bundler gem.

### Notes

If bundler version is before 2.0, then `github.https` setting is set to true.

This project rocks and uses MIT-LICENSE.
