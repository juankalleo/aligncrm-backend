# frozen_string_literal: true

# == Schema Information
#
# Table name: eventos
#
#  id            :uuid             not null, primary key
#  titulo        :string           not null
#  descricao     :text
#  tipo          :integer          default("reuniao"), not null
#  data_inicio   :datetime         not null
#  data_fim      :datetime
#  dia_inteiro   :boolean          default(FALSE)
#  projeto_id    :uuid
#  localizacao   :string
#  link_reuniao  :string
#  cor           :string
#  lembrete      :integer
#  criador_id    :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Evento < ApplicationRecord
  # Auditoria
  has_paper_trail

  # Enums
  enum tipo: {
    reuniao: 0,
    prazo: 1,
    lembrete: 2,
    marco: 3,
    outro: 4
  }, _prefix: true

  # Associações
  belongs_to :projeto, optional: true
  belongs_to :criador, class_name: "Usuario"
  has_and_belongs_to_many :participantes, class_name: "Usuario", join_table: "evento_participantes"

  # Validações
  validates :titulo, presence: true, length: { minimum: 2, maximum: 200 }
  validates :tipo, presence: true
  validates :data_inicio, presence: true
  validate :data_fim_apos_data_inicio

  # Scopes
  scope :proximos, -> { where("data_inicio >= ?", Time.current).order(:data_inicio) }
  scope :no_periodo, ->(inicio, fim) { where(data_inicio: inicio..fim) }
  scope :do_projeto, ->(projeto_id) { where(projeto_id: projeto_id) }

  private

  def data_fim_apos_data_inicio
    return unless data_inicio.present? && data_fim.present?
    
    if data_fim < data_inicio
      errors.add(:data_fim, "deve ser posterior à data de início")
    end
  end
end
