# frozen_string_literal: true

class ProjetoSolicitacaoPolicy < ApplicationPolicy
  def index?
    user.present? && record.projeto.proprietario_id == user.id
  end

  def show?
    user.present? && (record.usuario_id == user.id || record.projeto.proprietario_id == user.id || user.admin?)
  end

  def create?
    user.present? && !record.projeto.membro?(user) && record.usuario_id == user.id
  end

  # allow the public "create_by_code" endpoint to use the same rules as create
  def create_by_code?
    create?
  end

  def update?
    # only admin or manager can approve/reject (per new requirement)
    user.present? && (user.admin? || user.manager?)
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:projeto).where(projetos: { proprietario_id: user.id })
      end
    end
  end
end
