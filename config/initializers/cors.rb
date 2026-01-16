# Configuração do CORS para permitir requisições do frontend

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Desenvolvimento
    origins "http://localhost:3000", "http://127.0.0.1:3000"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization", "X-Total-Count", "X-Total-Pages"],
      credentials: true,
      max_age: 86400
  end

  # Produção
  allow do
    origins "https://aligncrm.com.br", "https://www.aligncrm.com.br"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization", "X-Total-Count", "X-Total-Pages"],
      credentials: true,
      max_age: 86400
  end
end
