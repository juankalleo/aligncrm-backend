# frozen_string_literal: true

# Per-request instrumentation to detect when `Rails.logger` becomes
# an instance of `Logger::Formatter` (the root cause for `tagged` NoMethodError).
# Appends diagnostic entries to /tmp/rails_logger_state.log so we can correlate
# the time, request and backtrace on the production server.
class CaptureLoggerFlip
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      logger_obj = Rails.logger
      logger_class = logger_obj.class
    rescue => e
      File.open('/tmp/rails_logger_state.log', 'a') do |f|
        f.puts("#{Time.now.utc.iso8601} PID=#{Process.pid} THREAD=#{Thread.current.object_id} ERROR checking Rails.logger: #{e.class}: #{e.message}")
      end
      logger_class = nil
    end

    if logger_class == Logger::Formatter
      File.open('/tmp/rails_logger_state.log', 'a') do |f|
        f.puts("=== Logger flip detected #{Time.now.utc.iso8601} PID=#{Process.pid} THREAD=#{Thread.current.object_id} ===")
        f.puts("Request: #{env['REQUEST_METHOD']} #{env['PATH_INFO']} from #{env['REMOTE_ADDR'] || env['HTTP_X_FORWARDED_FOR']}")
        f.puts("Logger object: #{logger_obj.inspect}")
        f.puts("Caller (top 20):")
        f.puts(caller(0, 20).join("\n"))
        f.puts("ENV keys snapshot: #{env.keys.select { |k| k =~ /HTTP|REMOTE|REQUEST/ }.join(', ')}")
        f.puts("---\n")
      end
    end

    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before(0, CaptureLoggerFlip)
