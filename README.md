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
  path = File.readlines('.ext_bundler').first
else
  File.write('.ext_bundler', path = `gem path ext_bundler`.strip)
end

load File.join(path, 'lib', 'ext_bundler', 'bundler.rb')

...
```

In your project .gitignore:

```
...

.ext_bundler

...
```

In some other gem's gemspec file:

```ruby
# gem_name.gemspec
...

Gem::Specification.new do |s|

  ...

  s.add_dependency 'some_other_gem', github: 'account_name/repo_name'

  ...

end
```

This project rocks and uses MIT-LICENSE.
