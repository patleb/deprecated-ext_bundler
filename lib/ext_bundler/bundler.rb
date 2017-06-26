unless defined?(Bundler::EXT_BUNDLER_LOADED)
  module Bundler
    class << self
      attr_accessor :sourced_gems, :sourced_gems_computed

      module WithSource
        def gemfile_sourced
          @_gemfile_sourced ||= root.join('Gemfile.sourced')
        end

        def gemfile_deploy
          @_gemfile_deploy ||= root.join('Gemfile.deploy')
        end

        def definition(unlock = nil)
          super

          unless sourced_gems_computed || !sourced_gems
            @definition = Definition.build(default_gemfile, default_lockfile, unlock)
            self.sourced_gems_computed = true
          end

          @definition
        end

        def default_gemfile
          @_default_gemfile ||= begin
            default_file = super

            if ARGV[0] == 'update' && File.exist?(gemfile_deploy)
              default_file = gemfile_deploy
            end

            default_file
          end
        end
      end
      prepend WithSource
    end

    Dsl.class_eval do
      class << self
        module WithSource
          def evaluate(gemfile, lockfile, unlock)
            return super unless (paths = Bundler.sourced_gems)

            File.open(Bundler.gemfile_sourced, "w") do |f|
              paths.each do |name, options|
                options = options.each_with_object([]) do |(key, value), memo|
                  memo << "#{key}: '#{value}'"
                end
                f.puts("gem '#{name}', #{options.join(', ')}")
              end
            end

            if Bundler::VERSION < '2.0'
              File.open(Bundler.gemfile_deploy, 'w') do |f|
                f.puts 'Bundler.settings["github.https"] = true'
                f.puts File.read(gemfile)
              end
            else
              FileUtils.copy(gemfile, Bundler.gemfile_deploy)
            end

            File.open(Bundler.gemfile_deploy, 'a') do |f|
              File.readlines(Bundler.gemfile_sourced).each do |line|
                f.puts line
              end
            end

            super(Bundler.gemfile_deploy, lockfile, unlock)
          end
        end
        prepend WithSource
      end
    end
  end

  module Gem
    Specification.class_eval do
      module WithSource
        def add_dependency(gem, *requirements)
          options = requirements.last
          options = if options.is_a?(Hash) && options.instance_of?(Hash)
            requirements.pop
          else
            {}
          end

          if options.any?
            Bundler.sourced_gems ||= {}
            Bundler.sourced_gems[gem] = options
          end

          super
        end
      end
      prepend WithSource
    end
  end

  if Bundler::VERSION < '2.0'
    Bundler.settings["github.https"] = true
  end

  module Bundler
    EXT_BUNDLER_LOADED = true
  end
end
