# frozen_string_literal: true

# Seeds para desenvolvimento do Align CRM
# Execute: rails db:seed

puts "🌱 Iniciando seeds do Align CRM..."

# Criar usuário admin
admin = Usuario.find_or_create_by!(email: "admin@aligncrm.com") do |u|
  u.nome = "Administrador"
  u.password = "admin123"
  u.role = :admin
  u.ativo = true
end
puts "✅ Admin criado: #{admin.email}"

# Criar usuários de exemplo
usuarios = [
  { nome: "Maria Silva", email: "maria@aligncrm.com", role: :manager },
  { nome: "João Santos", email: "joao@aligncrm.com", role: :user },
  { nome: "Ana Costa", email: "ana@aligncrm.com", role: :user },
  { nome: "Pedro Oliveira", email: "pedro@aligncrm.com", role: :viewer }
]

usuarios.each do |attrs|
  usuario = Usuario.find_or_create_by!(email: attrs[:email]) do |u|
    u.nome = attrs[:nome]
    u.password = "senha123"
    u.role = attrs[:role]
    u.ativo = true
  end
  puts "✅ Usuário criado: #{usuario.email}"
end

# Criar projetos de exemplo
maria = Usuario.find_by(email: "maria@aligncrm.com")

projetos_data = [
  {
    nome: "Website Redesign",
    descricao: "Redesenho completo do website corporativo com foco em UX/UI moderna",
    status: :em_andamento,
    cor: "#7c6be6"
  },
  {
    nome: "App Mobile",
    descricao: "Desenvolvimento do aplicativo mobile para iOS e Android",
    status: :planejamento,
    cor: "#6366f1"
  },
  {
    nome: "API Integration",
    descricao: "Integração com APIs de terceiros e microsserviços",
    status: :em_andamento,
    cor: "#8b5cf6"
  }
]

projetos_data.each do |attrs|
  projeto = Projeto.find_or_create_by!(nome: attrs[:nome]) do |p|
    p.descricao = attrs[:descricao]
    p.status = attrs[:status]
    p.cor = attrs[:cor]
    p.proprietario = maria
    p.data_inicio = Date.current
    p.data_fim = 3.months.from_now
  end
  
  # Adicionar membros
  Usuario.where.not(id: maria.id).limit(2).each do |u|
    projeto.adicionar_membro(u)
  end
  
  puts "✅ Projeto criado: #{projeto.nome}"
end

# Criar workspaces de teste (empresas)
owner = admin
ws_const = 'Workspace'.safe_constantize
if ws_const
  # Choose up to 3 distinct users to be workspace owners. If fewer than 3 distinct users
  # exist, create only as many workspaces as there are distinct users to avoid
  # validations that restrict one workspace per user.
  distinct_users = Usuario.limit(3).to_a.uniq

  if distinct_users.empty?
    puts "⚠️ Nenhum usuário disponível para criar workspaces; pulando seed de workspaces"
  else
    # Create one workspace per distinct user (max 3)
    workspace_defs = [
      { nome: 'Empresa Alpha', codigo: 'ALPHA' },
      { nome: 'Corp Beta', codigo: 'BETA' },
      { nome: 'Grupo Gamma', codigo: 'GAMMA' }
    ]

    created_workspaces = []
    workspace_defs.first(distinct_users.size).each_with_index do |attrs, idx|
      owner_for_ws = distinct_users[idx]
      w = ws_const.find_or_create_by!(nome: attrs[:nome]) do |rec|
        rec.codigo = attrs[:codigo]
        rec.proprietario = owner_for_ws
      end
      created_workspaces << w
    end

    # Assign existing projects to the created workspaces (round-robin)
    Projeto.all.limit(3).each_with_index do |p, i|
      p.update(workspace: created_workspaces[i % created_workspaces.size])
    end

    # Ensure each created workspace has a default 'Geral' project and add all users to it
    created_workspaces.each do |w|
      geral = Projeto.find_or_create_by!(nome: "Geral - #{w.nome}") do |p|
        p.descricao = "Projeto geral automático do workspace #{w.nome}"
        p.status = :planejamento
        p.cor = '#7c6be6'
        p.proprietario = w.proprietario
        p.workspace = w
        p.data_inicio = Date.current
      end

      Usuario.find_each do |u|
        geral.adicionar_membro(u)
      end
    end

    puts "✅ Workspaces criados: #{created_workspaces.count}"
  end
else
  # Fallback: create rows directly if model constant isn't loaded yet
  require 'securerandom'
  now = Time.now.utc
  conn = ActiveRecord::Base.connection
  if conn.table_exists?('workspaces')
    id = SecureRandom.uuid
    conn.execute(sanitize_sql_array([
      "INSERT INTO workspaces (id, nome, codigo, proprietario_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)",
      id, 'Empresa Alpha', 'ALPHA', owner.id, now, now
    ]))
    puts "✅ Workspaces criados (inserts: 1)"
  else
    puts "⚠️ Workspaces table not present yet; skipping workspace seed"
  end
end

# Criar tarefas de exemplo
projeto = Projeto.first

tarefas_data = [
  { titulo: "Revisar mockups da landing page", status: :todo, prioridade: :alta },
  { titulo: "Implementar autenticação JWT", status: :em_progresso, prioridade: :urgente },
  { titulo: "Testar fluxo de checkout", status: :revisao, prioridade: :media },
  { titulo: "Documentar endpoints da API", status: :backlog, prioridade: :baixa },
  { titulo: "Setup do ambiente de staging", status: :concluida, prioridade: :alta },
  { titulo: "Code review do módulo de pagamentos", status: :todo, prioridade: :media }
]

tarefas_data.each_with_index do |attrs, index|
  Tarefa.find_or_create_by!(titulo: attrs[:titulo], projeto: projeto) do |t|
    t.descricao = "Descrição detalhada da tarefa: #{attrs[:titulo]}"
    t.status = attrs[:status]
    t.prioridade = attrs[:prioridade]
    t.criador = maria
    t.responsavel = Usuario.all.sample
    t.prazo = rand(1..14).days.from_now
    t.ordem = index
  end
end
puts "✅ Tarefas criadas: #{Tarefa.count}"

# Criar links de exemplo
links_data = [
  { nome: "GitHub - Frontend", url: "https://github.com/align/frontend", categoria: :github },
  { nome: "GitHub - Backend", url: "https://github.com/align/backend", categoria: :github },
  { nome: "Documentação API", url: "https://docs.aligncrm.com", categoria: :documentacao },
  { nome: "Ambiente de Staging", url: "https://staging.aligncrm.com", categoria: :ambiente }
]

links_data.each do |attrs|
  Link.find_or_create_by!(nome: attrs[:nome]) do |l|
    l.url = attrs[:url]
    l.categoria = attrs[:categoria]
    l.projeto = projeto
    l.criador = admin
  end
end
puts "✅ Links criados: #{Link.count}"

puts ""
puts "🎉 Seeds concluídos com sucesso!"
puts ""
puts "📧 Credenciais de acesso:"
puts "   Admin: admin@aligncrm.com / admin123"
puts "   User:  maria@aligncrm.com / senha123"
