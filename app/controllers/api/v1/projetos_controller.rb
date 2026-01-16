# frozen_string_literal: true

module Api
  module V1
    class ProjetosController < ApplicationController
      before_action :set_projeto, only: [:show, :update, :destroy, :estatisticas, :historico]

      # GET /api/v1/projetos
      def index
        projetos = Projeto.do_usuario(current_user)
                          .includes(:proprietario, :membros)
                          .ordenados

        render_paginated(projetos, ProjetoSerializer)
      end

      # GET /api/v1/projetos/:id
      def show
        authorize @projeto
        render_success(ProjetoSerializer.new(@projeto).as_json)
      end

      # POST /api/v1/projetos
      def create
        # extract membros_ids before building model (not an attribute on Projeto)
        pp = projeto_params
        membros_ids = Array(pp.delete(:membros_ids)).map(&:to_s)

        @projeto = current_user.projetos_criados.build(pp)

        if @projeto.save
          # add creator as membro so they have project membership
          @projeto.adicionar_membro(current_user)
          # attach provided membros
          membros_ids.each do |uid|
            usuario = Usuario.find_by(id: uid, ativo: true)
            @projeto.adicionar_membro(usuario) if usuario
          end
          # attach capa if uploaded via multipart
          if params[:capa].present?
            @projeto.capa.attach(params[:capa])
          end
          registrar_acao(:criar)
          render_success(
            ProjetoSerializer.new(@projeto).as_json,
            "Projeto criado com sucesso",
            :created
          )
        else
          render_error(
            "Erro ao criar projeto",
            :unprocessable_entity,
            @projeto.errors.full_messages
          )
        end
      end

      # PATCH /api/v1/projetos/:id
      def update
        authorize @projeto

        # extract membros ids to update project members separately
        pp = projeto_params
        membros_ids = Array(pp.delete(:membros_ids)).map(&:to_s)

        if @projeto.update(pp)
          # update membros: sync given list (add missing, remove absent)
          if membros_ids.present?
            # add new members
            membros_ids.each do |uid|
              usuario = Usuario.find_by(id: uid, ativo: true)
              @projeto.adicionar_membro(usuario) if usuario
            end
            # remove members not in list (but keep owner)
            @projeto.membros.each do |m|
              next if m.id == @projeto.proprietario_id
              @projeto.remover_membro(m) unless membros_ids.include?(m.id.to_s)
            end
          end

          # attach/replace capa if uploaded (accept top-level or nested :projeto[:capa])
          uploaded_capa = params[:capa].presence || params.dig(:projeto, :capa).presence
          if uploaded_capa
            @projeto.capa.purge if @projeto.capa.attached?
            @projeto.capa.attach(uploaded_capa)
          end
          registrar_acao(:atualizar)
          render_success(
            ProjetoSerializer.new(@projeto).as_json,
            "Projeto atualizado com sucesso"
          )
        else
          render_error(
            "Erro ao atualizar projeto",
            :unprocessable_entity,
            @projeto.errors.full_messages
          )
        end
      end

      # DELETE /api/v1/projetos/:id
      def destroy
        authorize @projeto
        registrar_acao(:excluir)
        @projeto.destroy
        render_success(nil, "Projeto excluído com sucesso")
      end

      # POST /api/v1/projetos/reordenar
      def reordenar
        # Expect payload: { ids: [id1, id2, ...] }
        ids = params[:ids] || []
        ActiveRecord::Base.transaction do
          ids.each_with_index do |id, index|
            Projeto.where(id: id).update_all(ordem: index)
          end
        end

        render_success(nil, "Ordem dos projetos atualizada")
      end

      # GET /api/v1/projetos/:id/estatisticas
      def estatisticas
        authorize @projeto

        render_success({
          tarefasTotal: @projeto.tarefas_total,
          tarefasConcluidas: @projeto.tarefas_concluidas,
          tarefasEmProgresso: @projeto.tarefas_em_progresso,
          membrosAtivos: @projeto.membros_ativos.count,
          progressoPercentual: @projeto.progresso_percentual
        })
      end

      # GET /api/v1/projetos/:id/historico
      def historico
        authorize @projeto

        registros = Historico.where(entidade: :projeto, entidade_id: @projeto.id)
                            .or(Historico.where(entidade: :tarefa, entidade_id: @projeto.tarefas.pluck(:id)))
                            .includes(:usuario)
                            .recentes

        render_paginated(registros, HistoricoSerializer)
      end

      private

      def set_projeto
        @projeto = Projeto.find(params[:id])
      end

      def projeto_params
        # support both top-level params and nested `projeto` payloads
        source = params[:projeto].present? ? params.require(:projeto).permit! : params

        permitted = source.permit(:nome, :descricao, :observacoes, :status, :cor, :icone, :data_inicio, :data_fim, :data_fim_prevista, :workspace_id, :capa, membros_ids: [])

        # normalize data_fim_prevista -> data_fim if provided
        if permitted[:data_fim].blank? && permitted[:data_fim_prevista].present?
          permitted[:data_fim] = permitted.delete(:data_fim_prevista)
        end

        permitted
      end

      def registrar_acao(acao)
        Historico.registrar!(
          acao: acao,
          entidade: :projeto,
          entidade_id: @projeto.id,
          entidade_nome: @projeto.nome,
          usuario: current_user,
          ip: request.remote_ip
        )
      end
    end
  end
end
