# Align CRM - Backend Rails API

## Descrição
Backend API do sistema CRM Align, construído com Ruby on Rails em modo API-only.

## Requisitos
- Ruby 3.2+
- Rails 7.1+
- PostgreSQL 14+
- Redis (para ActionCable e cache)

## Instalação

```bash
# Instalar dependências
bundle install

# Configurar banco de dados
rails db:create
rails db:migrate
rails db:seed

# Iniciar servidor
rails server -p 3001
```

## Estrutura do Projeto

```
app/
├── controllers/    # Controllers da API
├── models/         # Models ActiveRecord
├── services/       # Regras de negócio complexas
├── policies/       # Autorização (Pundit)
├── serializers/    # Serialização JSON
├── poros/          # Plain Old Ruby Objects
├── jobs/           # Background Jobs
└── mailers/        # Emails transacionais

config/
├── initializers/   # Configurações
├── routes.rb       # Rotas da API
└── database.yml    # Configuração do DB
```

## API Endpoints

### Autenticação
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/register` - Registro
- `POST /api/v1/auth/logout` - Logout
- `GET /api/v1/auth/me` - Usuário atual

### Projetos
- `GET /api/v1/projetos` - Listar projetos
- `POST /api/v1/projetos` - Criar projeto
- `GET /api/v1/projetos/:id` - Detalhes do projeto
- `PATCH /api/v1/projetos/:id` - Atualizar projeto
- `DELETE /api/v1/projetos/:id` - Excluir projeto

### Tarefas
- `GET /api/v1/projetos/:projeto_id/tarefas` - Listar tarefas
- `POST /api/v1/tarefas` - Criar tarefa
- `GET /api/v1/tarefas/:id` - Detalhes da tarefa
- `PATCH /api/v1/tarefas/:id` - Atualizar tarefa
- `DELETE /api/v1/tarefas/:id` - Excluir tarefa

### Usuários
- `GET /api/v1/usuarios` - Listar usuários (admin)
- `POST /api/v1/usuarios` - Criar usuário (admin)
- `GET /api/v1/usuarios/:id` - Detalhes do usuário
- `PATCH /api/v1/usuarios/:id` - Atualizar usuário

### Histórico
- `GET /api/v1/historico` - Listar histórico

## Licença
Proprietário - Align CRM
