unless defined?(Bundler::NORMAL_GEMFILE)
  module Bundler
    NORMAL_GEMFILE = '#### NORMAL GEMFILE ####'
    SOURCED_GEMS = '#### SOURCED GEMS ####'
    SUPPORTED_KEYS = %w(group groups git branch ref tag require submodules platform platforms)

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

        if File.exist?(ext_gemfile)
          update_ext_gemfile
          FileUtils.copy(ext_lockfile, normal_lockfile)
        else
          create_ext_gemfile
          FileUtils.copy(normal_lockfile, ext_lockfile)
        end

        update_default_gemfile
        @_default_gemfile
      end

      def update_default_gemfile
        Bundler.settings['gemfile'] = File.basename(@_default_gemfile = ext_gemfile)
      end

      def ext_lockfile
        @_ext_lockfile ||= Pathname.new("#{ext_gemfile}.lock").untaint
      end

      def ext_gemfile
        @_ext_gemfile ||= root.join('ExtGemfile').untaint
      end

      def update_ext_gemfile
        content = File.read(normal_gemfile)
        content = File.read(ext_gemfile).sub(
          /#{NORMAL_GEMFILE}(.*)#{SOURCED_GEMS}/m,
          "#{NORMAL_GEMFILE}\n#{content}#{SOURCED_GEMS}"
        )
        File.write(ext_gemfile, content)
      end

      def create_ext_gemfile
        File.open(ext_gemfile, 'w') do |f|
          if Bundler::VERSION < '2.0'
            f.puts 'Bundler.settings["github.https"] = true'
          end
          f.puts NORMAL_GEMFILE
          f.puts File.read(normal_gemfile)
          f.puts SOURCED_GEMS
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
            return super unless Bundler.sourced_gems

            Bundler.create_ext_gemfile
            Bundler.update_default_gemfile

            builder = new
            File.open(Bundler.ext_gemfile, 'a') do |f|
              Bundler.sourced_gems.each do |name, opts_list|
                opts = opts_list.each_with_object({}) do |opts, memo|
                  opts = opts.dup
                  builder.send(:normalize_options, name, [">= 0"], opts)
                  memo.merge!(opts)
                end.select do |key, _value|
                  Bundler::SUPPORTED_KEYS.include?(key)
                end.each_with_object([]) do |(key, value), memo|
                  case value
                  when Array
                    memo << "#{key}: [:#{value.map(&:to_s).join(', :')}]" unless value.empty?
                  when String, Symbol
                    memo << "#{key}: '#{value}'"
                  else
                    memo << "#{key}: #{value}"
                  end
                end
                f.puts("gem '#{name}', #{opts.join(', ')}")
              end
            end
            builder.eval_gemfile(Bundler.ext_gemfile)
            builder.to_definition(lockfile, unlock)
          end
        end
        prepend WithSource
      end
    end
  end

  module Gem
    Specification.class_eval do
      module WithSource
        def add_runtime_dependency(gem, *requirements)
          opts = requirements.last.is_a?(Hash) ? requirements.pop.dup : {}

          if opts.any?
            Bundler.sourced_gems ||= {}
            Bundler.sourced_gems[gem] ||= []
            Bundler.sourced_gems[gem] << opts
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
