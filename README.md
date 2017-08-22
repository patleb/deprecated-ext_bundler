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

  s.add_dependency 'another_dev_gem', group: :development, require: false

  # ...
end
```

Supported keys are:

- :group, :groups
- :github, :git, :branch, :ref, :tag, :submodules
- :require
- :platform, :platforms

After running `bundle install` or `bundle update`, `ExtGemfile` is added or updated.

You also have to run `bundle install` again to replace your `Gemfile.lock` with a `ExtGemfile.lock`.

### Bundler configurations

After running `bundle install` or `bundle update`, your `.bundle/config` will be updated accordingly with:

- `BUNDLE_EXT_BUNDLER` set to the current library path
- `BUNDLE_GITHUB__HTTPS` set to true
- `BUNDLE_GEMFILE` set to `ExtGemfile`

### Upgrading

Clear `.bundle` directory within your project after updating `ext_bundler` gem.

### Rails server

If you don't want to run `bundle exec rails server`, you could specify the extended gemfile with:

`BUNDLE_GEMFILE=ExtGemfile rails server`

### Capistrano

The new Gemfile used must be `ExtGemfile` and could be configured by capistrano-bundler like this:

```ruby
# config/deploy.rb

set :bundle_gemfile, -> { 'ExtGemfile' }
```

Bundler also needs to know where to find `ext_bundler` and can be configured by [ExtCapistrano](https://github.com/patleb/ext_capistrano/blob/master/lib/capistrano/tasks/ext_capistrano/deploy.rb#L59);

### Passenger + Nginx

Passenger needs to know where is the `ExtGemfile` and can be configured by [ExtCapistrano](https://github.com/patleb/ext_capistrano/blob/master/config/nginx.app.conf.erb#L29).

### Development

```ruby
# Gemfile

if ENV['EXT_BUNDLER']
  require 'pathname'
  gem_path = Pathname.new('~/path_to_gem/ext_bundler').expand_path
  gem 'ext_bundler', path: gem_path.to_s
  load(Bundler.settings['ext_bundler'] ||= gem_path.join('lib/ext_bundler/bundler.rb').to_s)
else
  load(Bundler.settings['ext_bundler'] ||= File.join(
      (File.exist?('EXT_BUNDLER') ? File.readlines('EXT_BUNDLER').first : `gem path ext_bundler`).strip,
      'lib', 'ext_bundler', 'bundler.rb'
    )
  )
end
```

### License

This project rocks and uses MIT-LICENSE.
