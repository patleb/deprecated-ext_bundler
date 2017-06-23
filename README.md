# ExtBundler

### Installation

```bash
$ gem install ext_bundler
```

### Usage

```ruby
# Gemfile
source 'https://rubygems.org'

if File.exist? '.ext_bundler'
  path = File.readlines('.ext_bundler').first
else
  File.write('.ext_bundler', path = `gem path ext_bundler`.strip)
end

load File.join(path, 'lib', 'ext_bundler', 'bundler_decorator.rb')

...
```

This project rocks and uses MIT-LICENSE.
