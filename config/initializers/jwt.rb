# Configuração JWT

module JwtConfig
  SECRET_KEY = Rails.application.credentials.dig(:jwt, :secret_key) || ENV.fetch("JWT_SECRET_KEY", "align_dev_secret_key_change_in_production")
  ALGORITHM = "HS256"
  EXPIRATION_TIME = 7.days
  ISSUER = "align-crm"
end
