unless defined?(Bundler::NORMAL_GEMFILE)
  module Bundler
    NORMAL_GEMFILE = '#### NORMAL GEMFILE ####'
    SOURCED_GEMS = '#### SOURCED GEMS ####'

    class << self
      attr_accessor :sourced_gems, :sourced_gems_computed

      def normal_lockfile
        @_normal_lockfile ||= Pathname.new("#{normal_gemfile}.lock").untaint
      end

      def normal_gemfile
        @_normal_gemfile ||= root.join('Gemfile').untaint
      end

      alias_method :old_default_gemfile, :default_gemfile
      def default_gemfile
        return @_default_gemfile if defined?(@_default_gemfile)

        if File.exist?(gemfile_ext)
          update_gemfile_ext
          FileUtils.copy(lockfile_ext, normal_lockfile)
        else
          create_gemfile_ext
        end

        update_default_gemfile
      end

      def update_default_gemfile
        Bundler.settings['gemfile'] = @_default_gemfile = gemfile_ext
      end

      def lockfile_ext
        @_lockfile_ext ||= Pathname.new("#{gemfile_ext}.lock").untaint
      end

      def gemfile_ext
        @_gemfile_ext ||= root.join('GemfileExt').untaint
      end

      def update_gemfile_ext
        content = File.read(normal_gemfile)
        content = File.read(gemfile_ext).sub(
          /#{NORMAL_GEMFILE}(.*)#{SOURCED_GEMS}/m,
          "#{NORMAL_GEMFILE}\n#{content}#{SOURCED_GEMS}"
        )
        File.write(gemfile_ext, content)
      end

      def create_gemfile_ext
        File.open(gemfile_ext, 'w') do |f|
          if Bundler::VERSION < '2.0'
            f.puts 'Bundler.settings["github.https"] = true'
          end
          f.puts NORMAL_GEMFILE
          f.puts File.read(normal_gemfile)
        end
      end

      def root
        @_root ||= old_default_gemfile.dirname.expand_path
      end


      module WithSource
        def definition(unlock = nil)
          super

          unless sourced_gems_computed || !sourced_gems
            @definition = Definition.build(default_gemfile, default_lockfile, unlock)
            self.sourced_gems_computed = true
          end

          @definition
        end
      end
      prepend WithSource
    end

    Dsl.class_eval do
      class << self
        module WithSource
          def evaluate(gemfile, lockfile, unlock)
            return super unless (paths = Bundler.sourced_gems)

            Bundler.create_gemfile_ext

            File.open(Bundler.gemfile_ext, 'a') do |f|
              f.puts Bundler::SOURCED_GEMS
              paths.each do |name, options|
                options = options.each_with_object([]) do |(key, value), memo|
                  memo << "#{key}: '#{value}'"
                end
                f.puts("gem '#{name}', #{options.join(', ')}")
              end
            end

            Bundler.update_default_gemfile

            super(Bundler.gemfile_ext, lockfile, unlock)
          end
        end
        prepend WithSource
      end
    end
  end

  module Gem
    Dependency.class_eval do
      module WithSource
        def requirements_list
          list = super

          if list[0].is_a?(Hash)
            list = list[0]
          end

          list
        end
      end
      prepend WithSource
    end

    Requirement.class_eval do
      attr_writer :source

      module WithSource
        def as_list
          if @source
            [@source]
          else
            super
          end
        end
      end
      prepend WithSource

      class << self
        module WithSource
          def create(input)
            if input.is_a?(Array) && (source = input[0]).is_a?(Hash)
              requirement = super([])
              requirement.source = source
              requirement
            else
              super
            end
          end

          def parse(obj)
            requirement =
              case obj
              when Hash
                Gem::Requirement::DefaultRequirement
              when Symbol
                @was_symbol = true
                return Gem::Requirement::DefaultRequirement
              when String
                if @was_symbol
                  Gem::Requirement::DefaultRequirement
                else
                  super
                end
              else
                super
              end
            @was_symbol = false
            requirement
          end
        end
        prepend WithSource
      end
    end

    Specification.class_eval do
      module WithSource
        def add_runtime_dependency(gem, *requirements)
          source = requirements.last
          source = if source.is_a?(Hash) && source.instance_of?(Hash)
            requirements.pop
          else
            {}
          end

          if source.any?
            Bundler.sourced_gems ||= {}
            Bundler.sourced_gems[gem] = source
          end

          super
        end
        alias_method :add_dependency, :add_runtime_dependency
      end
      prepend WithSource
    end
  end

  if Bundler::VERSION < '2.0'
    Bundler.settings["github.https"] = true
  end
end
