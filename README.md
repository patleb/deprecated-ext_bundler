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

ext_bundler_cache = '.bundle/ext_bundler_cache'
if File.exist? ext_bundler_cache
  ext_bundler_path = File.readlines(ext_bundler_cache).first
else
  ext_bundler_path = File.join(`gem path ext_bundler`.strip, 'lib', 'ext_bundler', 'bundler.rb')
  File.write(ext_bundler_cache, ext_bundler_path)
end
load(ext_bundler_path)

# ...
```

Add `.bundle` to your project .gitignore if not already added.

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

After running `bundle`, a `Gemfile.urls` is added which contains remote gem sources.

Then, you can run `bundle install` and remote sources will added.

Every time `Gemfile.urls` must be updated (for example, after a `bundle update`), you must run `bundle` afterward.

### Upgrading

Clear `.bundle` directory within your project after updating ext_bundler gem.

### Notes

If bundler version is before 2.0, then `github.https` setting is set to true.

### TODO

- group definition

This project rocks and uses MIT-LICENSE.
