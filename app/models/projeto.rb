# frozen_string_literal: true

# == Schema Information
#
# Table name: projetos
#
#  id              :uuid             not null, primary key
#  nome            :string           not null
#  descricao       :text
#  status          :integer          default("planejamento"), not null
#  cor             :string           default("#7c6be6")
#  icone           :string
#  data_inicio     :date
#  data_fim        :date
#  proprietario_id :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class Projeto < ApplicationRecord
  # Auditoria
  has_paper_trail

  # Enums
  enum status: {
    planejamento: 0,
    em_andamento: 1,
    pausado: 2,
    concluido: 3,
    cancelado: 4
  }, _prefix: true

  # Associações
  belongs_to :proprietario, class_name: "Usuario"
  has_many :projeto_membros, dependent: :destroy
  has_many :membros, through: :projeto_membros, source: :usuario
  has_many :tarefas, dependent: :destroy
  has_many :fluxogramas, dependent: :destroy
  has_many :eventos, dependent: :nullify
  has_many :arquivos, dependent: :nullify
  has_many :links, dependent: :nullify
  belongs_to :workspace, optional: true

  # Validações
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :status, presence: true
  validates :cor, format: { with: /\A#[0-9A-Fa-f]{6}\z/, allow_blank: true }
  validate :data_fim_apos_data_inicio

  # Scopes
  scope :ativos, -> { where.not(status: [:concluido, :cancelado]) }
  scope :por_nome, -> { order(:nome) }
  scope :ordenados, -> { order(:ordem, :nome) }
  scope :recentes, -> { order(created_at: :desc) }
  scope :do_usuario, ->(usuario) {
    left_joins(:projeto_membros)
      .where("projetos.proprietario_id = ? OR projeto_membros.usuario_id = ?", usuario.id, usuario.id)
      .distinct
  }

  # Métodos
  def tarefas_total
    tarefas.count
  end

  # Active Storage
  has_one_attached :capa

  # Set initial order when creating projects
  before_create :definir_ordem_inicial

  def definir_ordem_inicial
    max_ordem = Projeto.maximum(:ordem) || -1
    self.ordem = max_ordem + 1
  end

  def tarefas_concluidas
    tarefas.where(status: :concluida).count
  end

  def tarefas_em_progresso
    tarefas.where(status: :em_progresso).count
  end

  def progresso_percentual
    return 0 if tarefas_total.zero?
    ((tarefas_concluidas.to_f / tarefas_total) * 100).round
  end

  def membros_ativos
    membros.ativos
  end

  def adicionar_membro(usuario)
    projeto_membros.find_or_create_by(usuario: usuario)
  end

  def remover_membro(usuario)
    projeto_membros.find_by(usuario: usuario)&.destroy
  end

  def membro?(usuario)
    proprietario_id == usuario.id || projeto_membros.exists?(usuario: usuario)
  end

  private

  def data_fim_apos_data_inicio
    return unless data_inicio.present? && data_fim.present?
    
    if data_fim < data_inicio
      errors.add(:data_fim, "deve ser posterior à data de início")
    end
  end
end
