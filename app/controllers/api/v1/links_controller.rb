# frozen_string_literal: true

module Api
  module V1
    class LinksController < ApplicationController
      # GET /api/v1/links or /api/v1/projetos/:projeto_id/links or /api/v1/workspaces/:workspace_id/links
      def index
        links = Link.all

        if params[:projeto_id].present?
          links = links.where(projeto_id: params[:projeto_id])
        elsif params[:workspace_id].present?
          workspace = ::Workspace.find(params[:workspace_id])
          projetos_ids = workspace.projetos.pluck(:id)
          links = links.where(projeto_id: projetos_ids)
        end

        render_success(links.order(created_at: :desc).as_json)
      end

      # POST /api/v1/links or /api/v1/workspaces/:workspace_id/links
      def create
        params_hash = link_params
        
        # If no projeto_id but workspace_id is in route, use first project from workspace
        if params_hash[:projeto_id].blank? && params[:workspace_id].present?
          workspace = ::Workspace.find(params[:workspace_id])
          authorize workspace
          projeto = workspace.projetos.first
          if projeto.blank?
            return render_error('Workspace não possui projetos. Crie um projeto primeiro.', :unprocessable_entity)
          end
          params_hash[:projeto_id] = projeto.id
        end
        
        link = Link.new(params_hash)
        link.criador = current_user

        if link.save
          render_success(link.as_json, 'Link criado', :created)
        else
          render_error('Erro ao criar link', :unprocessable_entity, link.errors.full_messages)
        end
      end

      # PATCH /api/v1/links/:id
      def update
        link = Link.find(params[:id])
        if link.update(link_params)
          render_success(link.as_json, 'Link atualizado')
        else
          render_error('Erro ao atualizar link', :unprocessable_entity, link.errors.full_messages)
        end
      end

      # DELETE /api/v1/links/:id
      def destroy
        link = Link.find(params[:id])
        link.destroy
        render_success(nil, 'Link excluído com sucesso')
      end

      private

      def link_params
        # Accept both wrapped (params[:link]) and unwrapped formats
        source = params[:link].present? ? params.require(:link) : params
        permitted = source.permit(:nome, :url, :descricao, :categoria, :projeto_id, :projetoId)
        
        # Normalize projetoId to projeto_id
        if permitted[:projetoId].present? && permitted[:projeto_id].blank?
          permitted[:projeto_id] = permitted.delete(:projetoId)
        end
        
        permitted
      end
    end
  end
end
