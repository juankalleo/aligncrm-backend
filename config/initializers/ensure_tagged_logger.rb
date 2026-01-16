# Ensure the running logger always supports `tagged` for request-time safety.
# This middleware re-wraps malformed loggers at request start so middleware
# or controllers calling `logger.tagged` won't raise. Kept minimal and safe.
begin
  class EnsureTaggedLogger
    LOG_PATH = '/tmp/rails_logger_state.log'
    @@last_class = nil
    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        current = (defined?(Rails) && Rails.logger) ? Rails.logger.class.to_s : 'nil'
        tagged_ok = defined?(Rails) && Rails.logger&.respond_to?(:tagged)
        if @@last_class != current
          begin
            File.open(LOG_PATH, 'a') do |f|
              f.puts("#{Time.now.utc.iso8601} Rails.logger class change: #{current} tagged?=#{tagged_ok}")
              f.puts(caller.first(10).join("\n"))
              f.puts("---")
            end
          rescue StandardError
            # ignore file write errors
          end
          @@last_class = current
        end

        unless tagged_ok
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
