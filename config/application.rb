require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JjpLite
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths += Dir[Rails.root.join('app', 'mixins', '*.rb')]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # devise overrides
    config.to_prepare do
      Devise::SessionsController.layout "devise"
    end

    # remove field with errors nonsense
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      html_tag
    }

    # which aseets to precompile
    config.assets.precompile += %w( screen.css admin.css site.js admin.js )

    # new callback behaviour
    config.active_record.raise_in_transactional_callbacks = true
  end
end
