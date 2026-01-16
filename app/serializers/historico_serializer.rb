# frozen_string_literal: true

class HistoricoSerializer < ActiveModel::Serializer
  attributes :id, :acao, :entidade, :entidade_id, :entidade_nome,
             :usuario_id, :detalhes, :ip, :criado_em

  belongs_to :usuario, serializer: UsuarioSerializer

  def criado_em
    object.created_at.iso8601
  end
end
