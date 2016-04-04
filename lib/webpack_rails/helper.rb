# view helper to resolve bundle asset file url (falling back to passthrough)

module WebpackRails
  module Helper
    def webpack_rails_config
      Rails.application.config.webpack_rails
    end

    def webpack_rails_task
      WebpackRails::Task
    end

    def webpack_bundle_asset(bundle_filename)
      config = webpack_rails_config

      # when sprockets integration is enabled, run_webpack is called there instead
      unless config[:sprockets_integration]
        webpack_rails_task.run_webpack(config)
      end

      if config[:dev_server]
        "#{config[:protocol]}://#{config[:host]}:#{config[:port]}/#{bundle_filename}"
      else
        bundle_filename
      end
    end
  end
end
