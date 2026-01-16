# frozen_string_literal: true

# Middleware to catch unhandled exceptions and write full diagnostics to disk.
# Helps capture the full backtrace when `tagged` NoMethodError occurs in production.
class ExceptionLoggerMiddleware
  LOG_PATH = '/tmp/rails_exceptions.log'

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue Exception => e
    begin
      File.open(LOG_PATH, 'a') do |f|
        f.puts("=== Exception captured #{Time.now.utc.iso8601} PID=#{Process.pid} THREAD=#{Thread.current.object_id} ===")
        f.puts("Request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']} from #{env['REMOTE_ADDR'] || env['HTTP_X_FORWARDED_FOR']}")
        f.puts("Exception: #{e.class} - #{e.message}")
        f.puts("Rails.logger class: #{(defined?(Rails) && Rails.logger) ? Rails.logger.class : 'nil'}")
        f.puts("Backtrace:")
        f.puts(e.backtrace.join("\n"))
        f.puts("Environment snapshot keys: #{env.keys.select { |k| k =~ /HTTP|REMOTE|REQUEST/ }.join(', ')}")
        f.puts("---\n")
      end
    rescue => write_err
      warn "ExceptionLoggerMiddleware failed to write: ", write_err.message
    end

    raise
  end
end

if defined?(Rails)
  Rails.application.config.middleware.insert_before(0, ExceptionLoggerMiddleware)
end
