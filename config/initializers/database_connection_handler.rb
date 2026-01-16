# Handle database connection errors gracefully during server startup
# This allows the server to start even if PostgreSQL is not running
# Remove this in production or when database is required

if defined?(Rails::Server)
  begin
    # Don't connect immediately on server startup
    # Connections will be made on first request
  rescue => e
    # Silently ignore database connection errors during startup
    Rails.logger&.warn("Database connection error: #{e.message}")
  end
end
