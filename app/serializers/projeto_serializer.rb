# frozen_string_literal: true

class ProjetoSerializer < ActiveModel::Serializer
  attributes :id, :nome, :descricao, :observacoes, :status, :cor, :icone,
             :data_inicio, :data_fim, :proprietario_id,
             :tarefas_total, :tarefas_concluidas, :capa_url,
             :criado_em, :atualizado_em

  belongs_to :proprietario, serializer: UsuarioSerializer
  has_many :membros, serializer: UsuarioSerializer

  def tarefas_total
    object.tarefas_total
  end

  def tarefas_concluidas
    object.tarefas_concluidas
  end

  def criado_em
    object.created_at.iso8601
  end

  def atualizado_em
    object.updated_at.iso8601
  end

  def capa_url
    return nil unless object.capa.attached?
    host = ENV.fetch('API_HOST', 'localhost')
    port = ENV.fetch('API_PORT', '3001')
    Rails.application.routes.url_helpers.rails_blob_url(object.capa, host: host, port: port, protocol: 'http')
  end

  attribute :workspace do
    next nil unless object.workspace
    { id: object.workspace.id, nome: object.workspace.nome }
  end
end
