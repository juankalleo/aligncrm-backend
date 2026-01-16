# frozen_string_literal: true

class ProjetoPolicy < ApplicationPolicy
  def show?
    record.membro?(user) || user.admin?
  end

  def update?
    record.proprietario_id == user.id || user.admin?
  end

  def destroy?
    record.proprietario_id == user.id || user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.do_usuario(user)
      end
    end
  end
end
