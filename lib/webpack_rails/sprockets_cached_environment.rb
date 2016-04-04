require 'sprockets'
require 'sprockets/cached_environment'

module WebpackRails
  class SprocketsCachedEnvironment < ::Sprockets::CachedEnvironment
    def initialize(environment)
      # ensure webpack-dev-server is running or watcher has finished building
      WebpackRails::Task.run_webpack(environment.webpack_task_config)

      super
    end
  end
end
