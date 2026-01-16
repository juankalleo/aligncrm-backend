# frozen_string_literal: true

module Api
  module V1
    class ProjetoSolicitacoesController < ApplicationController
      # don't run set_projeto for public create_by_code endpoint
      before_action :set_projeto, except: [:create_by_code, :minhas]
      before_action :set_solicitacao, only: [:show, :update]

      # GET /api/v1/solicitacoes/minhas
      def minhas
        solicitacoes = ProjetoSolicitacao.where(usuario: current_user)
                                         .where(status: :pendente)
                                         .includes(projeto: :workspace)
                                         .order(created_at: :desc)
        
        render_paginated(solicitacoes, ProjetoSolicitacaoSerializer)
      end

      # GET /api/v1/projetos/:projeto_id/solicitacoes
      def index
        solicitacoes = ProjetoSolicitacao.where(projeto: @projeto).includes(:usuario)
        authorize ProjetoSolicitacao.new(projeto: @projeto, usuario: current_user), :index?

        render_paginated(solicitacoes, ProjetoSolicitacaoSerializer)
      end

      # GET /api/v1/projetos/:projeto_id/solicitacoes/:id
      def show
        authorize @solicitacao
        render_success(ProjetoSolicitacaoSerializer.new(@solicitacao).as_json)
      end

      # POST /api/v1/projetos/:projeto_id/solicitacoes
      def create
        if @projeto.membro?(current_user)
          return render_error('Você já é membro deste grupo', :bad_request)
        end

        if ProjetoSolicitacao.exists?(usuario: current_user, projeto: @projeto)
          return render_error('Você já solicitou entrada neste projeto', :unprocessable_entity)
        end

        @solicitacao = ProjetoSolicitacao.new(projeto: @projeto, usuario: current_user, mensagem: params[:mensagem])
        authorize @solicitacao

        if @solicitacao.save
          render_success(ProjetoSolicitacaoSerializer.new(@solicitacao).as_json, "Solicitação enviada", :created)
        else
          render_error("Erro ao enviar solicitação", :unprocessable_entity, @solicitacao.errors.full_messages)
        end
      end

      # POST /api/v1/projetos/solicitacoes
      # body: { codigo: '...', nome: '...', mensagem: '...' }
      def create_by_code
        # try by explicit projeto_id param first
        projeto = Projeto.find_by(id: params[:projeto_id]) if params[:projeto_id].present?

        unless projeto
          codigo = params[:codigo].to_s.strip.presence
          nome = params[:nome].to_s.strip.presence

          if codigo
            uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
            if codigo.match?(uuid_regex)
              # Try to find projeto by UUID
              projeto = Projeto.find_by(id: codigo)
              # If not found, try workspace by UUID
              unless projeto
                workspace = Workspace.find_by(id: codigo)
                projeto = workspace&.projetos&.first
              end
            else
              # Try to find projeto by name
              projeto = Projeto.where('lower(nome) = ?', codigo.downcase).first
              # If not found, try workspace by name and get first project
              unless projeto
                workspace = Workspace.where('lower(nome) = ?', codigo.downcase).first
                projeto = workspace&.projetos&.first
              end
            end
          elsif nome
            # Try projeto first, then workspace
            projeto = Projeto.where('lower(nome) = ?', nome.downcase).first
            unless projeto
              workspace = Workspace.where('lower(nome) = ?', nome.downcase).first
              projeto = workspace&.projetos&.first
            end
          end
        end

        unless projeto
          return render_error('Grupo não encontrado', :not_found)
        end

        if projeto.membro?(current_user)
          return render_error('Você já é membro deste grupo', :bad_request)
        end

        if ProjetoSolicitacao.exists?(usuario: current_user, projeto: projeto)
          return render_error('Você já solicitou entrada neste projeto', :unprocessable_entity)
        end

        @solicitacao = ProjetoSolicitacao.new(projeto: projeto, usuario: current_user, mensagem: params[:mensagem])
        authorize @solicitacao

        if @solicitacao.save
          render_success(ProjetoSolicitacaoSerializer.new(@solicitacao).as_json, 'Solicitação enviada', :created)
        else
          render_error('Erro ao enviar solicitação', :unprocessable_entity, @solicitacao.errors.full_messages)
        end
      end

      # PATCH /api/v1/projetos/:projeto_id/solicitacoes/:id
      # expects param `status` => 'aprovado' or 'rejeitado'
      def update
        authorize @solicitacao

        if params[:status].present? && ProjetoSolicitacao.statuses.keys.include?(params[:status])
          @solicitacao.update(status: ProjetoSolicitacao.statuses[params[:status]])
          render_success(ProjetoSolicitacaoSerializer.new(@solicitacao).as_json, "Solicitação atualizada")
        else
          render_error("Status inválido", :unprocessable_entity)
        end
      end

      private

      def set_projeto
        @projeto = Projeto.find(params[:projeto_id])
      end

      def set_solicitacao
        @solicitacao = ProjetoSolicitacao.find(params[:id])
      end
    end
  end
end
