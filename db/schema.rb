# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_15_230742) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "arquivos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome", null: false
    t.string "nome_original", null: false
    t.integer "tipo", default: 0, null: false
    t.string "mimetype", null: false
    t.bigint "tamanho", null: false
    t.uuid "projeto_id"
    t.uuid "uploader_id", null: false
    t.datetime "created_at", null: false
    t.index ["nome"], name: "index_arquivos_on_nome"
    t.index ["projeto_id"], name: "index_arquivos_on_projeto_id"
    t.index ["tipo"], name: "index_arquivos_on_tipo"
    t.index ["uploader_id"], name: "index_arquivos_on_uploader_id"
  end

  create_table "evento_participantes", id: false, force: :cascade do |t|
    t.uuid "evento_id", null: false
    t.uuid "usuario_id", null: false
    t.index ["evento_id", "usuario_id"], name: "index_evento_participantes_on_evento_id_and_usuario_id", unique: true
    t.index ["evento_id"], name: "index_evento_participantes_on_evento_id"
    t.index ["usuario_id"], name: "index_evento_participantes_on_usuario_id"
  end

  create_table "eventos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "titulo", null: false
    t.text "descricao"
    t.integer "tipo", default: 0, null: false
    t.datetime "data_inicio", null: false
    t.datetime "data_fim"
    t.boolean "dia_inteiro", default: false
    t.uuid "projeto_id"
    t.string "localizacao"
    t.string "link_reuniao"
    t.string "cor"
    t.integer "lembrete"
    t.uuid "criador_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["criador_id"], name: "index_eventos_on_criador_id"
    t.index ["data_inicio"], name: "index_eventos_on_data_inicio"
    t.index ["projeto_id"], name: "index_eventos_on_projeto_id"
    t.index ["tipo"], name: "index_eventos_on_tipo"
  end

  create_table "fluxogramas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome", null: false
    t.text "descricao"
    t.uuid "projeto_id", null: false
    t.jsonb "dados", default: {}
    t.uuid "criador_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["criador_id"], name: "index_fluxogramas_on_criador_id"
    t.index ["nome"], name: "index_fluxogramas_on_nome"
    t.index ["projeto_id"], name: "index_fluxogramas_on_projeto_id"
  end

  create_table "historicos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "acao", null: false
    t.integer "entidade", null: false
    t.uuid "entidade_id", null: false
    t.string "entidade_nome"
    t.uuid "usuario_id", null: false
    t.jsonb "detalhes", default: {}
    t.string "ip"
    t.datetime "created_at", null: false
    t.index ["acao"], name: "index_historicos_on_acao"
    t.index ["created_at"], name: "index_historicos_on_created_at"
    t.index ["entidade", "entidade_id"], name: "index_historicos_on_entidade_and_entidade_id"
    t.index ["entidade"], name: "index_historicos_on_entidade"
    t.index ["entidade_id"], name: "index_historicos_on_entidade_id"
    t.index ["usuario_id"], name: "index_historicos_on_usuario_id"
  end

  create_table "links", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome", null: false
    t.string "url", null: false
    t.integer "categoria", default: 5, null: false
    t.text "descricao"
    t.uuid "projeto_id"
    t.uuid "criador_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categoria"], name: "index_links_on_categoria"
    t.index ["criador_id"], name: "index_links_on_criador_id"
    t.index ["nome"], name: "index_links_on_nome"
    t.index ["projeto_id"], name: "index_links_on_projeto_id"
  end

  create_table "projeto_membros", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "projeto_id", null: false
    t.uuid "usuario_id", null: false
    t.integer "papel", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["projeto_id", "usuario_id"], name: "index_projeto_membros_on_projeto_id_and_usuario_id", unique: true
    t.index ["projeto_id"], name: "index_projeto_membros_on_projeto_id"
    t.index ["usuario_id"], name: "index_projeto_membros_on_usuario_id"
  end

  create_table "projeto_solicitacoes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "projeto_id", null: false
    t.uuid "usuario_id", null: false
    t.text "mensagem"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["projeto_id", "usuario_id"], name: "index_projeto_solicitacoes_on_projeto_and_usuario", unique: true
    t.index ["projeto_id"], name: "index_projeto_solicitacoes_on_projeto_id"
    t.index ["usuario_id"], name: "index_projeto_solicitacoes_on_usuario_id"
  end

  create_table "projetos", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome", null: false
    t.text "descricao"
    t.integer "status", default: 0, null: false
    t.string "cor", default: "#7c6be6"
    t.string "icone"
    t.date "data_inicio"
    t.date "data_fim"
    t.uuid "proprietario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "observacoes"
    t.integer "ordem", default: 0, null: false
    t.uuid "workspace_id"
    t.index ["nome"], name: "index_projetos_on_nome"
    t.index ["ordem"], name: "index_projetos_on_ordem"
    t.index ["proprietario_id"], name: "index_projetos_on_proprietario_id"
    t.index ["status"], name: "index_projetos_on_status"
    t.index ["workspace_id"], name: "index_projetos_on_workspace_id"
  end

  create_table "tarefas", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "titulo", null: false
    t.text "descricao"
    t.integer "status", default: 0, null: false
    t.integer "prioridade", default: 1, null: false
    t.uuid "projeto_id"
    t.uuid "responsavel_id"
    t.uuid "criador_id", null: false
    t.datetime "prazo"
    t.integer "estimativa_horas"
    t.string "tags", default: [], array: true
    t.integer "ordem", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "arquivado", default: false, null: false
    t.datetime "arquivado_em"
    t.index ["arquivado"], name: "index_tarefas_on_arquivado"
    t.index ["criador_id"], name: "index_tarefas_on_criador_id"
    t.index ["prazo"], name: "index_tarefas_on_prazo"
    t.index ["prioridade"], name: "index_tarefas_on_prioridade"
    t.index ["projeto_id", "status", "ordem"], name: "index_tarefas_on_projeto_id_and_status_and_ordem"
    t.index ["projeto_id"], name: "index_tarefas_on_projeto_id"
    t.index ["responsavel_id"], name: "index_tarefas_on_responsavel_id"
    t.index ["status"], name: "index_tarefas_on_status"
  end

  create_table "usuarios", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 1, null: false
    t.boolean "ativo", default: true, null: false
    t.string "avatar_url"
    t.jsonb "preferencias", default: {}
    t.datetime "ultimo_login_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ativo"], name: "index_usuarios_on_ativo"
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["role"], name: "index_usuarios_on_role"
  end

  create_table "versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id"
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.jsonb "object_changes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "workspace_invites", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token", null: false
    t.uuid "workspace_id", null: false
    t.uuid "invited_by_id", null: false
    t.uuid "accepted_by_id"
    t.datetime "expires_at", null: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_by_id"], name: "index_workspace_invites_on_accepted_by_id"
    t.index ["invited_by_id"], name: "index_workspace_invites_on_invited_by_id"
    t.index ["token"], name: "index_workspace_invites_on_token", unique: true
    t.index ["workspace_id"], name: "index_workspace_invites_on_workspace_id"
  end

  create_table "workspaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "nome", null: false
    t.string "codigo"
    t.uuid "proprietario_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "storage_usado", default: 0, null: false
    t.index ["codigo"], name: "index_workspaces_on_codigo"
    t.index ["proprietario_id"], name: "index_workspaces_on_proprietario_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "arquivos", "projetos"
  add_foreign_key "arquivos", "usuarios", column: "uploader_id"
  add_foreign_key "evento_participantes", "eventos"
  add_foreign_key "evento_participantes", "usuarios"
  add_foreign_key "eventos", "projetos"
  add_foreign_key "eventos", "usuarios", column: "criador_id"
  add_foreign_key "fluxogramas", "projetos"
  add_foreign_key "fluxogramas", "usuarios", column: "criador_id"
  add_foreign_key "historicos", "usuarios"
  add_foreign_key "links", "projetos"
  add_foreign_key "links", "usuarios", column: "criador_id"
  add_foreign_key "projeto_membros", "projetos"
  add_foreign_key "projeto_membros", "usuarios"
  add_foreign_key "projetos", "usuarios", column: "proprietario_id"
  add_foreign_key "projetos", "workspaces"
  add_foreign_key "tarefas", "projetos"
  add_foreign_key "tarefas", "usuarios", column: "criador_id"
  add_foreign_key "tarefas", "usuarios", column: "responsavel_id"
  add_foreign_key "workspace_invites", "usuarios", column: "accepted_by_id"
  add_foreign_key "workspace_invites", "usuarios", column: "invited_by_id"
  add_foreign_key "workspace_invites", "workspaces"
end
