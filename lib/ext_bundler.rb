module ExtBundler
  def gem_dev(names, *args)
    if names.is_a? Hash
      @@gem_dev = names
      self.class.send :define_singleton_method, :gem_dev do
        @@gem_dev.find_all(&:last).map(&:first).each{ |gem| require gem }
      end
    else
      @gem_dev_path ||= File.readlines('.gem-dev').first.strip if File.exist?('.gem-dev')
      @@gem_dev[names.to_sym] ? gem(names, path: "#{@gem_dev_path}/#{names}", require: false) : gem(names, *args)
      @@gem_dev[names.to_sym] = (args.last.is_a?(Hash) ? args.last : {})[:require].nil?
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
    type = options.delete(:type).try(:to_sym)

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
