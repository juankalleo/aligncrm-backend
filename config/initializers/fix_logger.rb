# Ensure Rails.logger supports tagging in all environments and process managers.
# Some process managers (or misconfigured envs) may accidentally assign a
# Logger::Formatter or other object to `Rails.logger`. Detect that and replace
# it with a proper ActiveSupport::TaggedLogging wrapper early so middleware
# calling `logger.tagged` won't raise NoMethodError.
begin
  require 'logger'

  needs_fix = false
  if defined?(Rails)
    current = Rails.logger
    needs_fix = true unless current&.respond_to?(:tagged)
    needs_fix = true if current.is_a?(Logger::Formatter)
  else
    needs_fix = true
  end

  if needs_fix
    new_logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
    if defined?(Rails) && Rails.application&.config&.log_formatter
      new_logger.formatter = Rails.application.config.log_formatter
    end

    if defined?(Rails)
      Rails.logger = new_logger
      Rails.application.config.logger = new_logger if Rails.application&.config
      Rails.logger.info('Replaced malformed Rails.logger with ActiveSupport::TaggedLogging') rescue nil
    else
      # Fallback: set global logger
      ActiveRecord::Base.logger = new_logger if defined?(ActiveRecord::Base)
    end
  end
rescue StandardError => e
  warn "fix_logger initializer failed: "+e.message
end
