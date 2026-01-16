# Align CRM Backend - Rails API

# == Schema Information
#
# Este arquivo define a configuração principal do Rails para o Align CRM.
# O backend opera em modo API-only, sem views server-side.

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "active_storage/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module AlignBackend
  class Application < Rails::Application
    config.load_defaults 7.1

    # API-only mode
    config.api_only = true

    # Timezone
    config.time_zone = "Brasilia"
    config.active_record.default_timezone = :utc

    # Locale
    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = [:"pt-BR", :en]

    # Generators
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end

    # Active Job
    config.active_job.queue_adapter = :sidekiq

    # Autoload paths
    config.autoload_paths += %W[
      #{config.root}/app/services
      #{config.root}/app/policies
      #{config.root}/app/serializers
      #{config.root}/app/poros
    ]
  end
end
