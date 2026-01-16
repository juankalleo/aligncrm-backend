# frozen_string_literal: true

class UsuarioSerializer < ActiveModel::Serializer
  attributes :id, :nome, :email, :role, :ativo, :avatar_url, :criado_em, :atualizado_em

  attribute :projetos do
    Projeto.do_usuario(object).map do |p|
      { id: p.id, nome: p.nome }
    end
  end

  attribute :workspaces do
    ws_const = 'Workspace'.safe_constantize
    if ws_const
      ws_const.do_usuario(object).map do |w|
        { id: w.id, nome: w.nome }
      end
    else
      []
    end
  end

  def avatar_url
    return nil unless object.avatar.attached?
    host = ENV['APP_HOST'] || Rails.application.config.action_mailer.default_url_options[:host] || 'http://localhost:3001'
    Rails.application.routes.url_helpers.rails_blob_url(object.avatar, host: host)
  end

  def criado_em
    object.created_at.iso8601
  end

  def atualizado_em
    object.updated_at.iso8601
  end
end
