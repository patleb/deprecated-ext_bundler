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

Add `.bundle` and `Gemfile.lock` to your project `.gitignore` if not already added.

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

After running `bundle install` or `bundle update`, `GemfileExt` is added or updated.

You also have to run `bundle install` again to replace your `Gemfile.lock` with a `GemfileExt.lock`.

### Bundler configurations

After running `bundle install` or `bundle update`, your `.bundle/config` will be updated accordingly with:

- `BUNDLE_EXT_BUNDLER` set to the current library path
- `BUNDLE_GITHUB__HTTPS` set to true
- `BUNDLE_GEMFILE` set to the current `GemfileExt` path

### Upgrading

Clear `.bundle` directory within your project after updating `ext_bundler` gem.

### Rails server

If you don't want to run `bundle exec rails server`, you could specify the extended gemfile with:

`BUNDLE_GEMFILE=GemfileExt rails server`

### Capistrano

The new Gemfile used must be `GemfileExt` and could be configured by capistrano-bundler like this:

```ruby
# config/deploy.rb

set :bundle_gemfile, -> { 'GemfileExt' }
```

Bundler also needs to know where to find `ext_bundler` and can be configured by [Capee](https://github.com/patleb/capee/blob/master/lib/capistrano/tasks/capee/deploy.rb#L51);

### Passenger

Passenger needs to know where is the `GemfileExt` and can be configured by [Capee](https://github.com/patleb/capee/blob/master/config/nginx.app.conf.erb#L31).

This project rocks and uses MIT-LICENSE.
