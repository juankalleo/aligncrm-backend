# frozen_string_literal: true

module Api
  module V1
    class ArquivosController < ApplicationController
      # GET /api/v1/arquivos or /api/v1/projetos/:projeto_id/arquivos or /api/v1/workspaces/:workspace_id/arquivos
      def index
        arquivos = Arquivo.all

        if params[:projeto_id].present?
          arquivos = arquivos.where(projeto_id: params[:projeto_id])
        elsif params[:workspace_id].present?
          workspace = ::Workspace.find(params[:workspace_id])
          projetos_ids = workspace.projetos.pluck(:id)
          arquivos = arquivos.where(projeto_id: projetos_ids)
        elsif params[:projetoId].present?
          arquivos = arquivos.where(projeto_id: params[:projetoId])
        end

        render_success(arquivos.order(created_at: :desc).as_json)
      end

      # POST /api/v1/arquivos or /api/v1/workspaces/:workspace_id/arquivos
      def create
        # Expect multipart form with arquivo and projetoId or workspace_id from route
        projeto_id = params[:projetoId] || params[:projeto_id] || params[:projeto]&.[](:id)
        workspace = nil
        
        # If no projeto_id but workspace_id is in route, use first project from workspace
        if projeto_id.blank? && params[:workspace_id].present?
          workspace = ::Workspace.find(params[:workspace_id])
          authorize workspace
          projeto = workspace.projetos.first
          if projeto.blank?
            return render_error('Workspace não possui projetos. Crie um projeto primeiro.', :unprocessable_entity)
          end
          projeto_id = projeto.id
        else
          # Find workspace from projeto_id
          projeto = Projeto.find(projeto_id) if projeto_id.present?
          workspace = projeto.workspace if projeto
        end
        
        if projeto_id.blank?
          return render_error('Arquivo precisa pertencer a um projeto', :unprocessable_entity)
        end

        # Verifica o tamanho do arquivo antes de criar
        if params[:arquivo].present?
          tamanho_arquivo = params[:arquivo].size
          
          # Verifica se o workspace tem espaço suficiente
          if workspace && !workspace.tem_espaco_para?(tamanho_arquivo)
            storage_disponivel_mb = (workspace.storage_disponivel / 1.megabyte.to_f).round(2)
            tamanho_arquivo_mb = (tamanho_arquivo / 1.megabyte.to_f).round(2)
            return render_error(
              "Limite de armazenamento atingido. Disponível: #{storage_disponivel_mb}MB, Necessário: #{tamanho_arquivo_mb}MB",
              :unprocessable_entity
            )
          end
        end

        arquivo = Arquivo.new(uploader: current_user, projeto_id: projeto_id)

        if params[:arquivo].present?
          arquivo.file.attach(params[:arquivo])
          arquivo.nome = arquivo.file.filename.to_s
          arquivo.nome_original = arquivo.nome
          arquivo.mimetype = arquivo.file.content_type
          arquivo.tamanho = arquivo.file.byte_size
        end

        if arquivo.save
          # Atualiza o storage_usado do workspace
          workspace.atualizar_storage! if workspace
          render_success(arquivo.as_json, 'Arquivo criado', :created)
        else
          render_error('Erro ao criar arquivo', :unprocessable_entity, arquivo.errors.full_messages)
        end
      end

      # DELETE /api/v1/arquivos/:id
      def destroy
        arquivo = Arquivo.find(params[:id])
        workspace = arquivo.projeto.workspace if arquivo.projeto
        arquivo.destroy
        # Atualiza o storage_usado do workspace
        workspace.atualizar_storage! if workspace
        render_success(nil, 'Arquivo excluído com sucesso')
      end

      # GET /api/v1/arquivos/:id/download
      def download
        arquivo = Arquivo.find(params[:id])
        unless arquivo.file.attached?
          return render_error('Arquivo não encontrado', :not_found)
        end

        send_data arquivo.file.download, filename: arquivo.nome_original, type: arquivo.mimetype
      end
    end
  end
end
