# frozen_string_literal: true

class DominioSerializer < ActiveModel::Serializer
  attributes :id, :nome, :porta, :nginx_server, :expires_at, :notified, :criado_em, :atualizado_em

  def criado_em
    object.created_at.iso8601 if object.respond_to?(:created_at) && object.created_at
  end

  def atualizado_em
    object.updated_at.iso8601 if object.respond_to?(:updated_at) && object.updated_at
  end
end
