# SQLite setup script for Align CRM development
require 'active_record'
require 'bcrypt'

# Connect to SQLite database
db_path = 'db/development.sqlite3'
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: db_path
)

# Create schema
create_schema_sql = <<~SQL
  -- Users table
  CREATE TABLE IF NOT EXISTS usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR NOT NULL,
    email VARCHAR NOT NULL UNIQUE,
    password_digest VARCHAR NOT NULL,
    role INTEGER DEFAULT 1 NOT NULL,
    ativo BOOLEAN DEFAULT 1 NOT NULL,
    avatar_url VARCHAR,
    preferencias TEXT DEFAULT '{}',
    ultimo_login_em DATETIME,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS projetos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR NOT NULL,
    descricao TEXT,
    status VARCHAR DEFAULT 'ativo' NOT NULL,
    cor VARCHAR DEFAULT '#4f46e5',
    proprietario_id INTEGER NOT NULL REFERENCES usuarios(id),
    criador_id INTEGER NOT NULL REFERENCES usuarios(id),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS projeto_membros (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    projeto_id INTEGER NOT NULL REFERENCES projetos(id),
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(projeto_id, usuario_id)
  );

  CREATE TABLE IF NOT EXISTS tarefas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR NOT NULL,
    descricao TEXT,
    status VARCHAR DEFAULT 'todo' NOT NULL,
    prioridade VARCHAR DEFAULT 'media' NOT NULL,
    projeto_id INTEGER NOT NULL REFERENCES projetos(id),
    responsavel_id INTEGER REFERENCES usuarios(id),
    criador_id INTEGER NOT NULL REFERENCES usuarios(id),
    prazo DATETIME,
    estimativa_horas INTEGER,
    tags TEXT DEFAULT '[]',
    ordem INTEGER DEFAULT 0 NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS historicos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    acao INTEGER NOT NULL,
    entidade INTEGER NOT NULL,
    entidade_id INTEGER NOT NULL,
    entidade_nome VARCHAR,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    detalhes TEXT DEFAULT '{}',
    ip VARCHAR,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS fluxogramas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR NOT NULL,
    descricao TEXT,
    projeto_id INTEGER NOT NULL REFERENCES projetos(id),
    criador_id INTEGER NOT NULL REFERENCES usuarios(id),
    conteudo TEXT,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS eventos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR NOT NULL,
    descricao TEXT,
    criador_id INTEGER NOT NULL REFERENCES usuarios(id),
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME,
    local VARCHAR,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS arquivos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR NOT NULL,
    caminho VARCHAR NOT NULL,
    uploader_id INTEGER NOT NULL REFERENCES usuarios(id),
    tamanho INTEGER,
    tipo_arquivo VARCHAR,
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titulo VARCHAR NOT NULL,
    url VARCHAR NOT NULL,
    descricao TEXT,
    criador_id INTEGER NOT NULL REFERENCES usuarios(id),
    criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
  );

  CREATE TABLE IF NOT EXISTS versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_type VARCHAR NOT NULL,
    item_id INTEGER,
    event VARCHAR NOT NULL,
    whodunnit VARCHAR,
    object TEXT,
    object_changes TEXT,
    created_at DATETIME,
    updated_at DATETIME
  );

  CREATE TABLE IF NOT EXISTS active_storage_blobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key VARCHAR NOT NULL UNIQUE,
    filename VARCHAR NOT NULL,
    content_type VARCHAR,
    metadata TEXT,
    byte_size BIGINT NOT NULL,
    checksum VARCHAR,
    created_at DATETIME NOT NULL
  );

  CREATE TABLE IF NOT EXISTS active_storage_attachments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name VARCHAR NOT NULL,
    record_type VARCHAR NOT NULL,
    record_id INTEGER NOT NULL,
    blob_id INTEGER NOT NULL REFERENCES active_storage_blobs(id),
    created_at DATETIME NOT NULL
  );

  CREATE TABLE IF NOT EXISTS active_storage_variant_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    blob_id INTEGER NOT NULL REFERENCES active_storage_blobs(id),
    variation_digest VARCHAR NOT NULL
  );
SQL

# Execute the schema creation
sql_statements = create_schema_sql.split(';').map(&:strip).reject(&:empty?)
sql_statements.each do |statement|
  ActiveRecord::Base.connection.execute(statement + ';') rescue nil
end

puts "SQLite schema created!"

# Seed test users using direct SQL with properly hashed passwords
# BCrypt cost factor is typically 11 in production, but we use 4 for testing
salt = "$2a$04$" # BCrypt salt prefix (cost factor 4)

# Hash passwords using BCrypt with consistent parameters
password_admin = BCrypt::Password.create('admin123', cost: 4)
password_gerente = BCrypt::Password.create('gerente123', cost: 4)
password_user = BCrypt::Password.create('user123', cost: 4)

users_sql = [
  "INSERT OR IGNORE INTO usuarios (nome, email, password_digest, role, ativo, created_at, updated_at) VALUES ('Admin User', 'admin@aligncrm.com', '#{password_admin}', 3, 1, datetime('now'), datetime('now'));",
  "INSERT OR IGNORE INTO usuarios (nome, email, password_digest, role, ativo, created_at, updated_at) VALUES ('Gerente User', 'gerente@aligncrm.com', '#{password_gerente}', 2, 1, datetime('now'), datetime('now'));",
  "INSERT OR IGNORE INTO usuarios (nome, email, password_digest, role, ativo, created_at, updated_at) VALUES ('Regular User', 'user@aligncrm.com', '#{password_user}', 1, 1, datetime('now'), datetime('now'));"
]

users_sql.each do |statement|
  ActiveRecord::Base.connection.execute(statement) rescue nil
end

puts "Test users seeded!"
puts "✓ admin@aligncrm.com / admin123 (role: admin)"
puts "✓ gerente@aligncrm.com / gerente123 (role: manager)"
puts "✓ user@aligncrm.com / user123 (role: user)"
