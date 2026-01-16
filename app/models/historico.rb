# frozen_string_literal: true

# == Schema Information
#
# Table name: historicos
#
#  id            :uuid             not null, primary key
#  acao          :integer          not null
#  entidade      :integer          not null
#  entidade_id   :uuid             not null
#  entidade_nome :string
#  usuario_id    :uuid             not null
#  detalhes      :jsonb            default({})
#  ip            :string
#  created_at    :datetime         not null
#
class Historico < ApplicationRecord
  # Attribute types for enums
  attribute :acao, :integer
  attribute :entidade, :integer

  # Enums
  enum acao: {
    criar: 0,
    atualizar: 1,
    excluir: 2,
    arquivar: 3,
    restaurar: 4,
    login: 5,
    logout: 6,
    permissao_alterada: 7
  }, _prefix: true

  enum entidade: {
    projeto: 0,
    tarefa: 1,
    usuario: 2,
    arquivo: 3,
    link: 4,
    fluxograma: 5,
    evento: 6
  }, _prefix: true, _default: :usuario

  # Associações
  belongs_to :usuario

  # Validações
  validates :acao, presence: true
  validates :entidade, presence: true
  validates :entidade_id, presence: true

  # Scopes
  scope :recentes, -> { order(created_at: :desc) }
  scope :por_usuario, ->(usuario_id) { where(usuario_id: usuario_id) }
  scope :por_entidade, ->(entidade) { where(entidade: entidade) }
  scope :por_acao, ->(acao) { where(acao: acao) }
  scope :no_periodo, ->(inicio, fim) { where(created_at: inicio..fim) }

  # Métodos de classe
  def self.registrar!(acao:, entidade:, entidade_id:, usuario:, entidade_nome: nil, detalhes: {}, ip: nil)
    create!(
      acao: acao,
      entidade: entidade,
      entidade_id: entidade_id,
      entidade_nome: entidade_nome,
      usuario: usuario,
      detalhes: detalhes,
      ip: ip
    )
  end

  # Métodos de instância
  def descricao
    acao_texto = {
      "criar" => "criou",
      "atualizar" => "atualizou",
      "excluir" => "excluiu",
      "arquivar" => "arquivou",
      "restaurar" => "restaurou",
      "login" => "fez login",
      "logout" => "fez logout",
      "permissao_alterada" => "alterou permissões de"
    }[acao]

    "#{usuario.nome} #{acao_texto} #{entidade.humanize.downcase} #{entidade_nome}"
  end
end
