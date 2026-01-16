Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  config.cache_store = :memory_store

  # Show error pages for missing translations.
  # config.action_view.raise_on_missing_translations = true (API-only app, ActionView not available)

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Active Storage service (use local in development)
  config.active_storage.service = :local

  # Use inline Active Job execution in development to avoid requiring
  # a running Redis/Sidekiq instance for ActiveStorage analysis jobs.
  # Change to :async or :sidekiq in production as appropriate.
  config.active_job.queue_adapter = :inline

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true
end
