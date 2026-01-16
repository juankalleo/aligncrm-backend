# frozen_string_literal: true

class UsuarioPolicy < ApplicationPolicy
  def show?
    record.id == user.id || user.admin?
  end

  def update?
    record.id == user.id || user.admin?
  end

  def destroy?
    user.admin? && record.id != user.id
  end

  def avatar?
    record.id == user.id || user.admin?
  end

  def historico?
    record.id == user.id || user.admin?
  end
end
