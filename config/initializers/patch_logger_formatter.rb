# Temporary mitigation: ensure Logger::Formatter responds to `tagged` so
# unexpected replacements of `Rails.logger` with a Formatter don't crash
# the app while we investigate the root cause.
begin
  class Logger::Formatter
    # Accept tags and an optional block. This is a no-op formatter-level
    # implementation that yields to the block so calls like
    # `Rails.logger.tagged('X') { ... }` won't raise when `Rails.logger` is
    # wrongly set to a Formatter instance.
    def tagged(*_tags)
      if block_given?
        yield
      else
        # return self for call-chaining
        self
      end
    end
    
    # No-op tag stack operations used by ActiveSupport::TaggedLogging
    def clear_tags!
      # noop
    end

    def push_tags(*_tags)
      # noop
    end

    def pop_tags
      # noop
    end

    # Return an array-compatible tag stack expected by ActiveSupport::TaggedLogging
    def current_tags
      []
    end
  end
rescue StandardError => e
  warn "patch_logger_formatter initializer failed: #{e.class} - #{e.message}"
end
