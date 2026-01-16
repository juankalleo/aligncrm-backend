class WorkspacePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if record.proprietario_id == user.id

    # allow if user is member of any project inside the workspace
    record.projetos.joins(:projeto_membros).where(projeto_membros: { usuario_id: user.id }).exists?
  end

  def update?
    # Only proprietario or admin can update workspace
    return true if record.proprietario_id == user.id
    user.admin?
  end

  def projetos?
    show?
  end

  def usuarios?
    show?
  end

  def remover_usuario?
    show?
  end

  def solicitacoes?
    show?
  end

  class Scope < Scope
    def resolve
      Workspace.do_usuario(user)
    end
  end
end
