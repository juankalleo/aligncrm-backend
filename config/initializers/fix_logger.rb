# Ensure Rails.logger supports tagging in all environments and process managers.
# Some process managers may set logger or formatter incorrectly; force a TaggedLogging
# logger early so middleware that calls `logger.tagged` won't raise NoMethodError.
unless defined?(Rails) && Rails.logger&.respond_to?(:tagged)
  require 'logger'
  tagged = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
  tagged.formatter = Rails.application.config.log_formatter if Rails&.application&.config&.log_formatter
  Rails.logger = tagged
end
