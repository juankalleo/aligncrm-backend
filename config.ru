# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# Ensure Rails.logger responds to `tagged` as early as possible so Rack/middleware
# logging doesn't fail when requests arrive before initializers run.
begin
	if defined?(Rails)
		unless Rails.logger.respond_to?(:tagged) rescue true
			require 'active_support/tagged_logging'
			require 'active_support/logger'
			wrapped = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))
			Rails.logger = wrapped
			if defined?(Rails.application) && Rails.application.respond_to?(:config)
				Rails.application.config.logger = wrapped
			end
			wrapped.info('Replaced malformed Rails.logger with ActiveSupport::TaggedLogging in config.ru') rescue nil
		end
	end
rescue StandardError
	# best-effort: don't prevent boot on unexpected errors here
end

run Rails.application
