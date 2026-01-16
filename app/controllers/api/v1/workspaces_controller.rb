# frozen_string_literal: true

module Api
  module V1
    class WorkspacesController < ApplicationController
      # GET /api/v1/workspaces
      def index
        workspaces = ::Workspace.do_usuario(current_user).por_nome
        render_paginated(workspaces, ::WorkspaceSerializer)
      end

      # GET /api/v1/workspaces/:id
      def show
        workspace = ::Workspace.find(params[:id])
        authorize workspace
        render_success(::WorkspaceSerializer.new(workspace).as_json)
      end

      # POST /api/v1/workspaces
      def create
        workspace = ::Workspace.new(workspace_params)
        workspace.proprietario = current_user

        if workspace.save
          render_success(::WorkspaceSerializer.new(workspace).as_json, 'Workspace criado com sucesso', :created)
        else
          render_error('Erro ao criar workspace', :unprocessable_entity, workspace.errors.full_messages)
        end
      end

      # PATCH/PUT /api/v1/workspaces/:id
      def update
        workspace = ::Workspace.find(params[:id])
        authorize workspace

        if workspace.update(workspace_params)
          render_success(::WorkspaceSerializer.new(workspace).as_json, 'Workspace atualizado com sucesso')
        else
          render_error('Erro ao atualizar workspace', :unprocessable_entity, workspace.errors.full_messages)
        end
      end

      # GET /api/v1/workspaces/:id/projetos
      def projetos
        workspace = ::Workspace.find(params[:id])
        authorize workspace

        projetos = workspace.projetos
                           .includes(:proprietario, :membros)
                           .ordenados

        render_paginated(projetos, ::ProjetoSerializer)
      end

      # GET /api/v1/workspaces/:id/usuarios
      def usuarios
        workspace = ::Workspace.find(params[:id])
        authorize workspace

        usuarios = Usuario.do_workspace(workspace)
                          .ativos
                          .por_nome

        render_paginated(usuarios, ::UsuarioSerializer)
      end

      # DELETE /api/v1/workspaces/:id/usuarios/:usuario_id
      def remover_usuario
        workspace = ::Workspace.find(params[:id])
        authorize workspace
        
        usuario = Usuario.find(params[:usuario_id])
        
        # Remove user from all projects in this workspace
        ProjetoMembro.joins(:projeto)
                     .where(projetos: { workspace_id: workspace.id }, usuario_id: usuario.id)
                     .destroy_all
        
        render_success(nil, "Usuário removido do workspace com sucesso")
      end

      # GET /api/v1/workspaces/:id/solicitacoes
      def solicitacoes
        workspace = ::Workspace.find(params[:id])
        authorize workspace

        # Get all pending requests for projects in this workspace
        solicitacoes = ProjetoSolicitacao.joins(:projeto)
                                         .where(projetos: { workspace_id: workspace.id })
                                         .where(status: :pendente)
                                         .includes(:usuario, :projeto)
                                         .order(created_at: :desc)

        render_paginated(solicitacoes, ::ProjetoSolicitacaoSerializer)
      end

      private

      def workspace_params
        params.require(:workspace).permit(:nome, :codigo)
      end
    end
  end
end
