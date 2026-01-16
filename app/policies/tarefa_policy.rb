# frozen_string_literal: true

class TarefaPolicy < ApplicationPolicy
  def show?
    projeto_membro? || user.admin?
  end

  def create?
    # Allow creation of personal tasks (no project) or when user is a project member or admin
    return true if record.projeto.nil?
    projeto_membro? || user.admin?
  end

  def update?
    pode_editar?
  end

  def destroy?
    record.criador_id == user.id || record.projeto.proprietario_id == user.id || user.admin?
  end

  def reordenar?
    projeto_membro? || user.admin?
  end

  def atribuir?
    projeto_membro? || user.admin?
  end

  private

  def projeto_membro?
    return false unless record.projeto.present?
    record.projeto.membro?(user)
  end

  def pode_editar?
    record.criador_id == user.id ||
      record.responsavel_id == user.id ||
      record.projeto.proprietario_id == user.id ||
      user.admin?
  end
end
