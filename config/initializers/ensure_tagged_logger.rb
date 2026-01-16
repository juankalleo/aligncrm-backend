# Ensure the running logger always supports `tagged` for request-time safety.
# This middleware re-wraps malformed loggers at request start so middleware
# or controllers calling `logger.tagged` won't raise. Kept minimal and safe.
begin
  class EnsureTaggedLogger
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        unless defined?(Rails) && Rails.logger&.respond_to?(:tagged)
          require 'active_support/tagged_logging'
          require 'active_support/logger'
          new_logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
          if defined?(Rails) && Rails.application&.config&.log_formatter
            new_logger.formatter = Rails.application.config.log_formatter
          end
          if defined?(Rails)
            Rails.logger = new_logger
            Rails.application.config.logger = new_logger if Rails.application&.config
          end
        end
      rescue StandardError
        # best-effort, do not break requests
      end

      @app.call(env)
    end
  end

  if defined?(Rails)
    Rails.application.config.middleware.insert_before(0, EnsureTaggedLogger)
  end
rescue StandardError => e
  warn "ensure_tagged_logger initializer failed: #{e.message}"
end
