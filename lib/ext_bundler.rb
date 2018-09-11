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
      if File.exist? '.gem-dev'
        @gem_dev_paths ||= File.readlines('.gem-dev').map(&:strip).compact
        path = @gem_dev_paths.lazy.map{ |root| File.expand_path("#{root}/#{names}") }.find{ |path| Dir.exist? path }
      end
      @@gem_dev[names.to_sym] ? gem(names, path: path, require: false) : gem(names, *args)
      options = args.last.is_a?(Hash) ? args.last : {}
      groups = options[:group] ? Array(options[:group]) : options[:groups]
      @@gem_dev[names.to_sym] = {
        require: options[:require].nil?,
        groups: (groups || @groups.dup).map(&:to_sym),
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

    regexes =
      case type
      when :ref
        [
          /^  revision: (\w+)(?:\n  branch: \w+)?\n  specs:\n    #{name} \([\w\.]+\)$/m,
          /^  remote: .*\/#{name}.git\n  revision: (\w+)(?:\n  branch: \w+)?\n  specs:\n/m
        ]
      else
        [/^    #{name} \(([\w\.]+)\)$/]
      end
    version = regexes.lazy.map{ |regex| @gemfile_lock.match(regex) }.reject(&:nil?).first[1]

    case type
    when :ref
      options[:ref] = version
    when :tag
      options[:tag] = "#{name}-v#{version}"
    else
      args.unshift(version)
    end
    args << options

    [name, args]
  end
end
