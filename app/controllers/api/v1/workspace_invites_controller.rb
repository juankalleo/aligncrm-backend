# frozen_string_literal: true

module Api
  module V1
    class WorkspaceInvitesController < ApplicationController
      skip_before_action :authenticate_request, only: [:show, :accept]

      # POST /api/v1/workspaces/:id/invites
      def create
        workspace = Workspace.find(params[:id])
        # allow owners, admins and managers to create invites
        unless current_user.admin? || current_user.manager? || workspace.proprietario_id == current_user.id
          return render_error('Acesso negado', :forbidden)
        end

        invite = WorkspaceInvite.new(
          workspace: workspace,
          invited_by: current_user,
          expires_at: 30.minutes.from_now
        )

        if invite.save
          render_success({ token: invite.token, expires_at: invite.expires_at }, 'Convite criado')
        else
          render_error('Erro ao criar convite', :unprocessable_entity, invite.errors.full_messages)
        end
      end

      # GET /api/v1/invites/:token
      def show
        invite = WorkspaceInvite.find_by(token: params[:token])
        return render_error('Convite inválido', :not_found) unless invite

        if invite.usable?
          render_success({ workspace: { id: invite.workspace.id, nome: invite.workspace.nome }, expires_at: invite.expires_at })
        else
          render_error('Convite expirado ou já utilizado', :gone)
        end
      end

      # POST /api/v1/invites/:token/accept
      def accept
        invite = WorkspaceInvite.find_by(token: params[:token])
        return render_error('Convite inválido', :not_found) unless invite
        return render_error('Convite expirado ou já utilizado', :gone) unless invite.usable?

        # Register the user using AuthService
        nome = params[:nome]
        email = params[:email]
        senha = params[:senha]

        result = AuthService.register(nome: nome, email: email, senha: senha, ip: request.remote_ip)
        unless result[:success]
          return render_error(result[:error], :unprocessable_entity, result[:errors])
        end

        # Add the created user to all projects in the workspace so they are considered part of the workspace
        usuario_id = result[:data][:usuario][:id]
        usuario = Usuario.find_by(id: usuario_id)
        Projeto.where(workspace_id: invite.workspace_id).find_each do |p|
          p.adicionar_membro(usuario)
        end

        invite.mark_used!(usuario)

        render_success(result[:data], 'Conta criada e adicionada ao workspace', :created)
      end
    end
  end
end
