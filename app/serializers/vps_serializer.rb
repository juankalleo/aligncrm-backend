# frozen_string_literal: true

class VpsSerializer < ActiveModel::Serializer
  attributes :id, :nome, :login_root, :email_relacionado, :storage_gb, :comprado_em, :comprado_em_local, :projetos, :has_password, :criado_em, :atualizado_em

  def comprado_em
    object.comprado_em.iso8601 if object.respond_to?(:comprado_em) && object.comprado_em
  end

  def projetos
    object.projetos_list
  end

  def has_password
    object.has_password?
  end

  def criado_em
    object.created_at.iso8601 if object.respond_to?(:created_at) && object.created_at
  end

  def atualizado_em
    object.updated_at.iso8601 if object.respond_to?(:updated_at) && object.updated_at
  end
end
