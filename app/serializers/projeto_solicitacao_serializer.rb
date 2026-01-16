class ProjetoSolicitacaoSerializer < ActiveModel::Serializer
  attributes :id, :mensagem, :status, :criado_em, :atualizado_em

  attribute :usuario do
    { id: object.usuario.id, nome: object.usuario.nome, email: object.usuario.email }
  end

  attribute :projeto do
    { id: object.projeto.id, nome: object.projeto.nome }
  end

  def criado_em
    object.created_at.iso8601
  end

  def atualizado_em
    object.updated_at.iso8601
  end
end
