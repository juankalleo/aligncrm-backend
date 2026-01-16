# frozen_string_literal: true

module Api
  module V1
    class TarefasController < ApplicationController
      before_action :set_tarefa, only: [:show, :update, :destroy, :status, :reordenar, :atribuir]

      # GET /api/v1/projetos/:projeto_id/tarefas
      # GET /api/v1/workspaces/:workspace_id/tarefas
      def index
        incluir_arquivadas = params[:incluir_arquivadas] == 'true'

        # support both nested routes: /projetos/:projeto_id/tarefas and member route /workspaces/:id/tarefas
        if params[:projeto_id].present?
          projeto = Projeto.find(params[:projeto_id])
          authorize projeto, :show?

          tarefas = projeto.tarefas
          tarefas = tarefas.nao_arquivadas unless incluir_arquivadas
          tarefas = tarefas.includes(:responsavel, :criador).ordenadas

          render_paginated(tarefas, TarefaSerializer)
        elsif params[:workspace_id].present? || params[:id].present?
          workspace_id = params[:workspace_id] || params[:id]
          workspace = ::Workspace.find(workspace_id)
          authorize workspace

          tarefas = Tarefa.left_joins(:projeto)
                          .where('projetos.workspace_id = ? OR tarefas.projeto_id IS NULL', workspace.id)
          tarefas = tarefas.nao_arquivadas unless incluir_arquivadas
          tarefas = tarefas.includes(:projeto, :responsavel, :criador).ordenadas

          render_paginated(tarefas, TarefaSerializer)
        else
          render_error('Projeto ou workspace não informado', :bad_request)
        end
      end

      # GET /api/v1/tarefas/minhas
      def minhas
        # Return tasks where the current user is either the responsible or the creator
        tarefas = Tarefa.where('responsavel_id = :id OR criador_id = :id', id: current_user.id)
                      .includes(:projeto, :criador, :responsavel)
                      .ordenadas

        render_paginated(tarefas, TarefaSerializer)
      end

      # GET /api/v1/tarefas/:id
      def show
        authorize @tarefa
        render_success(TarefaSerializer.new(@tarefa).as_json)
      end

      # POST /api/v1/tarefas
      def create
        @tarefa = Tarefa.new(tarefa_params)
        @tarefa.criador = current_user
        authorize @tarefa

        if @tarefa.save
          registrar_acao(:criar)
          render_success(
            TarefaSerializer.new(@tarefa).as_json,
            "Tarefa criada com sucesso",
            :created
          )
        else
          render_error(
            "Erro ao criar tarefa",
            :unprocessable_entity,
            @tarefa.errors.full_messages
          )
        end
      end

      # PATCH /api/v1/tarefas/:id
      def update
        authorize @tarefa
        
        if @tarefa.update(tarefa_params)
          # capture previous changes to include in historico detalhes
          changes = @tarefa.previous_changes.transform_values do |v|
            { antigo: v[0], novo: v[1] }
          end
          Historico.registrar!(
            acao: :atualizar,
            entidade: :tarefa,
            entidade_id: @tarefa.id,
            entidade_nome: @tarefa.titulo,
            usuario: current_user,
            detalhes: changes,
            ip: request.remote_ip
          )
          render_success(
            TarefaSerializer.new(@tarefa).as_json,
            "Tarefa atualizada com sucesso"
          )
        else
          render_error(
            "Erro ao atualizar tarefa",
            :unprocessable_entity,
            @tarefa.errors.full_messages
          )
        end
      end

      # DELETE /api/v1/tarefas/:id
      def destroy
        authorize @tarefa
        registrar_acao(:excluir)
        @tarefa.destroy
        render_success(nil, "Tarefa excluída com sucesso")
      end

      # PATCH /api/v1/tarefas/:id/status
      def status
        authorize @tarefa

        antigo = @tarefa.status

        if @tarefa.update(status: params[:status])
          Historico.registrar!(
            acao: :atualizar,
            entidade: :tarefa,
            entidade_id: @tarefa.id,
            entidade_nome: @tarefa.titulo,
            usuario: current_user,
            detalhes: { status: { antigo: antigo, novo: params[:status] } },
            ip: request.remote_ip
          )
          render_success(
            TarefaSerializer.new(@tarefa).as_json,
            "Status atualizado com sucesso"
          )
        else
          render_error("Erro ao atualizar status", :unprocessable_entity)
        end
      end

      # PATCH /api/v1/tarefas/:id/reordenar
      def reordenar
        authorize @tarefa

        @tarefa.mover_para!(params[:novoStatus], params[:novaOrdem].to_i)
        render_success(nil, "Tarefa reordenada com sucesso")
      end

      # PATCH /api/v1/tarefas/:id/atribuir
      def atribuir
        authorize @tarefa

        responsavel = params[:usuarioId].present? ? Usuario.find(params[:usuarioId]) : nil
        
        if @tarefa.update(responsavel: responsavel)
          render_success(
            TarefaSerializer.new(@tarefa).as_json,
            responsavel ? "Tarefa atribuída com sucesso" : "Atribuição removida"
          )
        else
          render_error("Erro ao atribuir tarefa", :unprocessable_entity)
        end
      end

      # POST /api/v1/projetos/:projeto_id/tarefas/arquivar_concluidas
      # POST /api/v1/workspaces/:workspace_id/tarefas/arquivar_concluidas
      def arquivar_concluidas
        if params[:projeto_id].present?
          projeto = Projeto.find(params[:projeto_id])
          authorize projeto, :update?

          tarefas = projeto.tarefas.where(status: :concluida, arquivado: false)
        elsif params[:workspace_id].present? || params[:id].present?
          workspace_id = params[:workspace_id] || params[:id]
          workspace = ::Workspace.find(workspace_id)
          authorize workspace, :update?

          tarefas = Tarefa.left_joins(:projeto)
                          .where('projetos.workspace_id = ? OR tarefas.projeto_id IS NULL', workspace.id)
                          .where(status: :concluida, arquivado: false)
        else
          return render_error('Projeto ou workspace não informado', :bad_request)
        end

        count = 0
        tarefas.find_each do |tarefa|
          tarefa.arquivar!
          count += 1
        end

        render_success({ count: count }, "#{count} tarefa(s) arquivada(s) com sucesso")
      end

      private

      def set_tarefa
        @tarefa = Tarefa.find(params[:id])
      end

      def tarefa_params
        params.permit(
          :titulo, :descricao, :status, :prioridade, :projeto_id,
          :responsavel_id, :prazo, :estimativa_horas, tags: []
        )
      end

      def registrar_acao(acao)
        Historico.registrar!(
          acao: acao,
          entidade: :tarefa,
          entidade_id: @tarefa.id,
          entidade_nome: @tarefa.titulo,
          usuario: current_user,
          ip: request.remote_ip
        )
      end
    end
  end
end
