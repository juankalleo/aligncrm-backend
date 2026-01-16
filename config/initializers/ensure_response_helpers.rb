# Ensure the ResponseHelpers concern is loaded and included into ApplicationController
# This guarantees `render_success`, `render_error` and `render_paginated` are available
# in production/eager-load/process-manager environments.
ActiveSupport.on_load(:after_initialize) do
  begin
    path = Rails.root.join('app', 'controllers', 'concerns', 'response_helpers.rb')
    require_dependency path.to_s if File.exist?(path)
  rescue StandardError => e
    Rails.logger.error("Failed to require ResponseHelpers: ") if defined?(Rails) && Rails.logger
  end

  if defined?(ResponseHelpers) && defined?(ApplicationController)
    unless ApplicationController.included_modules.include?(ResponseHelpers)
      ApplicationController.include(ResponseHelpers)
      Rails.logger.info('ResponseHelpers included into ApplicationController') if defined?(Rails) && Rails.logger
    end
  end
end
