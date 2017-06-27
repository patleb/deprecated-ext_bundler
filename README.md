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

load(Bundler.settings['ext_bundler'] ||= File.join(
    (File.exist?('EXT_BUNDLER') ? File.readlines('EXT_BUNDLER').first : `gem path ext_bundler`).strip,
    'lib', 'ext_bundler', 'bundler.rb'
  )
)

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

After running `bundle install` or `bundle update`, `Gemfile.ext` is added or updated.

You also have to run `bundle install` again to replace your `Gemfile.lock` with a `Gemfile.ext.lock`.

### Capistrano

The new Gemfile used must be `Gemfile.ext` and could be configured by:

```ruby
# config/deploy.rb

set :bundle_gemfile, -> { release_path.join('Gemfile.ext') }
```

### Rails server

If you don't want to run `bundle exec rails server`, you could specify the extended gemfile with:

`BUNDLE_GEMFILE=Gemfile.ext rails server`

### Upgrading

Clear `.bundle` directory within your project after updating `ext_bundler` gem.

### Bundler configurations

After running `bundle install` or `bundle update`, your `.bundle/config` will be updated accordingly with:

- `BUNDLE_EXT_BUNDLER` set to the current library path
- `BUNDLE_GITHUB__HTTPS` set to true
- `BUNDLE_GEMFILE` set to the current `Gemfile.ext` path

This project rocks and uses MIT-LICENSE.
