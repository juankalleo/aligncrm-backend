# Ensure the ResponseHelpers concern is loaded and included into controllers.
# Include into ActionController::API as well so API controllers receive the helpers
# even if they don't load ApplicationController the usual way in some process managers.
ActiveSupport.on_load(:after_initialize) do
  begin
    path = Rails.root.join('app', 'controllers', 'concerns', 'response_helpers.rb')
    if File.exist?(path)
      require_dependency path.to_s
    else
      require_relative Rails.root.join('app', 'controllers', 'concerns', 'response_helpers').to_s rescue nil
    end
  rescue StandardError => e
    Rails.logger.error("Failed to require ResponseHelpers: #{e.message}") if defined?(Rails) && Rails.logger
  end

  if defined?(ResponseHelpers)
    begin
      if defined?(ActionController::API) && !ActionController::API.included_modules.include?(ResponseHelpers)
        ActionController::API.include(ResponseHelpers)
        Rails.logger.info('ResponseHelpers included into ActionController::API') if defined?(Rails) && Rails.logger
      end

      if defined?(ApplicationController) && !ApplicationController.included_modules.include?(ResponseHelpers)
        ApplicationController.include(ResponseHelpers)
        Rails.logger.info('ResponseHelpers included into ApplicationController') if defined?(Rails) && Rails.logger
      end
    rescue StandardError => e
      Rails.logger.error("Failed to include ResponseHelpers into controllers: #{e.message}") if defined?(Rails) && Rails.logger
    end
  else
    Rails.logger.warn('ResponseHelpers constant not defined after require') if defined?(Rails) && Rails.logger
  end
end
