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

group :development do
  load(Bundler.settings['ext_bundler'] ||= File.join(`gem path ext_bundler`.strip, 'lib', 'ext_bundler', 'bundler.rb'))
end

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

After running `bundle install` or `bundle update`, `Gemfile.sourced` and `Gemfile.deploy` are added or updated if there is any remote sources.

Which means you also have to run `bundle install` or `bundle update` again to update you `Gemfile.lock`.

### Capistrano

The new Gemfile used for deployment should be `Gemfile.deploy` and could be configured by:

```ruby
# config/deploy.rb

set :bundle_gemfile, -> { release_path.join('Gemfile.deploy') }
```

### Upgrading

Clear `.bundle` directory within your project after updating `ext_bundler` gem.

### Notes

If bundler version is before 2.0, then `github.https` setting is set to true.

This project rocks and uses MIT-LICENSE.
