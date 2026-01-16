source "https://rubygems.org"

ruby "3.3.10"

# Rails
gem "rails", "~> 7.1.0"
gem "pg", "~> 1.5"
gem "sqlite3", "~> 1.7"
gem "puma", "~> 6.4"

# Environment variables
gem "dotenv-rails", "~> 2.8"

# JSON API
gem "jbuilder", "~> 2.11"
gem "active_model_serializers", "~> 0.10.14"

# Autenticação & Autorização
gem "bcrypt", "~> 3.1"
gem "jwt", "~> 2.7"
gem "pundit", "~> 2.3"

# CORS
gem "rack-cors", "~> 2.0"

# Background Jobs
gem "sidekiq", "~> 7.2"
gem "redis", "~> 5.0"

# Upload de Arquivos
gem "active_storage_validations", "~> 1.1"
gem "image_processing", "~> 1.12"
gem "aws-sdk-s3", "~> 1.141"

# Utilitários
gem "bootsnap", require: false
gem "tzinfo-data", platforms: %i[windows jruby]
gem "kaminari", "~> 1.2"
gem "ransack", "~> 4.1"

# Auditoria
gem "paper_trail", "~> 15.1"

group :development, :test do
  gem "debug", platforms: %i[mri windows]
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"
  gem "pry-rails", "~> 0.3"
end

group :development do
  gem "annotate", "~> 3.2"
  gem "rubocop", "~> 1.59"
  gem "rubocop-rails", "~> 2.23"
  gem "rubocop-rspec", "~> 2.25"
  gem "listen", "~> 3.9"
  gem "wdm", ">= 0.1.0" if Gem.win_platform?
end

group :test do
  gem "shoulda-matchers", "~> 6.0"
  gem "simplecov", require: false
  gem "database_cleaner-active_record", "~> 2.1"
end
