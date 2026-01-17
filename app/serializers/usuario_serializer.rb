# frozen_string_literal: true

class UsuarioSerializer < ActiveModel::Serializer
  attributes :id, :nome, :email, :role, :ativo, :avatar_url, :criado_em, :atualizado_em

  attribute :projetos do
    # Avoid running a DB query here; expect controller to preload `projetos` when needed.
    if object.class.reflect_on_association(:projetos) && object.association(:projetos).loaded?
      object.projetos.map { |p| { id: p.id, nome: p.nome } }
    else
      []
    end
  end

  attribute :workspaces do
    # Avoid running a DB query here; expect controller to preload `workspaces` when needed.
    if object.class.reflect_on_association(:workspaces) && object.association(:workspaces).loaded?
      object.workspaces.map { |w| { id: w.id, nome: w.nome } }
    else
      []
    end
  end

  def avatar_url
    return nil unless object.avatar.attached?
    host = ENV.fetch('API_HOST', 'api.aligncrm.com.br')
    protocol = ENV.fetch('API_PROTOCOL', 'https')
    Rails.application.routes.url_helpers.rails_blob_url(object.avatar, host: host, protocol: protocol)
  end

  def criado_em
    object.created_at.iso8601
  end

  def atualizado_em
    object.updated_at.iso8601
  end
end
