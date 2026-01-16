# frozen_string_literal: true

class ProjetoSolicitacao < ApplicationRecord
  self.table_name = 'projeto_solicitacoes'
  belongs_to :projeto
  belongs_to :usuario

  enum status: { pendente: 0, aprovado: 1, rejeitado: 2 }

  validates :projeto, :usuario, presence: true
  validates :usuario_id, uniqueness: { scope: :projeto_id, message: "já solicitou entrada neste projeto" }

  after_update :apply_approval, if: :saved_change_to_status?

  private

  def apply_approval
    return unless status == "aprovado"

    projeto.adicionar_membro(usuario)
  end
end
