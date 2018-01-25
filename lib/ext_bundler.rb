module ExtBundler
  def gem_dev(names, *args)
    if names.is_a? Hash
      @@gem_dev = names
      self.class.send :define_singleton_method, :gem_dev do
        env = defined?(Rails.env) ? Rails.env.to_sym : false
        @@gem_dev.find_all do |_gem, options|
          groups = options[:groups]
          options[:require] && (groups.empty? || groups.include?(env))
        end.map(&:first).each{ |gem| require gem.to_s }
      end
    else
      @gem_dev_paths ||= File.readlines('.gem-dev').map(&:strip).compact
      path = @gem_dev_paths.lazy.map{ |root| File.expand_path("#{root}/#{names}") }.find{ |path| Dir.exist? path }
      @@gem_dev[names.to_sym] ? gem(names, path: path, require: false) : gem(names, *args)
      @@gem_dev[names.to_sym] = {
        require: (args.last.is_a?(Hash) ? args.last : {})[:require].nil?,
        groups: @groups.dup,
      }
    end
  end

  def gem_lock(name, *args)
    name, args = _gem_lock(name, *args)
    gem name, *args
  end

  def gem_lock_dev(name, *args)
    name, args = _gem_lock(name, *args)
    gem_dev name, *args
  end

  def _gem_lock(name, *args)
    @gemfile_lock ||= File.read('Gemfile.lock')
    options = args.last.is_a?(Hash) ? args.pop : {}
    type = options.delete(:type)&.to_sym

    version =
      case type
      when :ref
        /^  revision: (\w+)(?:\n  branch: \w+)?\n  specs:\n    #{name} \([\w\.]+\)$/m
      else
        /^    #{name} \(([\w\.]+)\)$/
      end
    version = @gemfile_lock.match(version)[1]

    if type
      options[type] = version
    else
      args.unshift(version)
    end
    args << options

    [name, args]
  end
end
