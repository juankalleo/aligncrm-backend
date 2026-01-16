# frozen_string_literal: true

# == Schema Information
#
# Table name: projeto_membros
#
#  id         :uuid             not null, primary key
#  projeto_id :uuid             not null
#  usuario_id :uuid             not null
#  papel      :integer          default("membro"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ProjetoMembro < ApplicationRecord
  # Enums
  enum papel: {
    membro: 0,
    colaborador: 1,
    lider: 2
  }, _prefix: true

  # Associações
  belongs_to :projeto
  belongs_to :usuario

  # Validações
  validates :usuario_id, uniqueness: { scope: :projeto_id, message: "já é membro deste projeto" }
  validates :papel, presence: true
end
