# frozen_string_literal: true

class EnableUuidExtension < ActiveRecord::Migration[7.1]
  def change
    # Only enable pgcrypto for PostgreSQL, skip for SQLite
    if connection.adapter_name == "PostgreSQL"
      begin
        enable_extension "pgcrypto"
      rescue ActiveRecord::StatementInvalid => e
        warn "Could not enable pgcrypto extension: #{e.message}. Continuing without it."
      end
    end
  end
end
