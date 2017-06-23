require "ext_bundler/configuration"

module ExtBundler
  class Engine < ::Rails::Engine
   
    # Initialize engine dependencies on wrapper application
    Gem.loaded_specs["ext_bundler"].dependencies.each do |d|
      begin
        require d.name
      rescue LoadError => e
        # Put exceptions here.
      end
    end
   
    # Uncomment if migrations need to be shared
    # initializer :append_migrations do |app|
    #   unless app.root.to_s.match root.to_s
    #     config.paths["db/migrate"].expanded.each do |expanded_path|
    #       app.config.paths["db/migrate"] << expanded_path
    #     end
    #   end
    # end
   
    config.to_prepare do
      # Dir[Engine.root.join("{app,lib}/**/*_decorator.rb")].each do |c|
      #   require_dependency(c)
      # end
    end
  end
end
