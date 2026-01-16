class FluxogramaSerializer < ActiveModel::Serializer
  attributes :id, :nome, :descricao, :projeto_id, :dados, :criador_id, :criado_em, :atualizado_em

  belongs_to :projeto, serializer: ProjetoSerializer
  belongs_to :criador, class_name: 'Usuario', serializer: UsuarioSerializer

  def criado_em
    object.created_at&.iso8601
  end

  def atualizado_em
    object.updated_at&.iso8601
  end
end
