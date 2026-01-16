# frozen_string_literal: true

class TarefaSerializer < ActiveModel::Serializer
  attributes :id, :titulo, :descricao, :status, :prioridade,
             :projeto_id, :responsavel_id, :prazo,
             :estimativa_horas, :tags, :ordem,
             :criado_em, :atualizado_em

  belongs_to :projeto, serializer: ProjetoSerializer
  belongs_to :responsavel, serializer: UsuarioSerializer

  def criado_em
    object.created_at.iso8601
  end

  def atualizado_em
    object.updated_at.iso8601
  end
end
