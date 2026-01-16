# frozen_string_literal: true

module Api
  module V1
    class HistoricoController < ApplicationController
      # GET /api/v1/historico
      def index
        registros = Historico.includes(:usuario).recentes

        # Filtros
        registros = registros.por_usuario(params[:usuarioId]) if params[:usuarioId].present?
        registros = registros.por_entidade(params[:entidade]) if params[:entidade].present?
        registros = registros.por_acao(params[:acao]) if params[:acao].present?
        
        if params[:dataInicio].present? && params[:dataFim].present?
          registros = registros.no_periodo(
            Time.zone.parse(params[:dataInicio]),
            Time.zone.parse(params[:dataFim])
          )
        end

        # support workspace-scoped historico
        if params[:workspace_id].present?
          workspace = ::Workspace.find(params[:workspace_id])
          project_ids = workspace.projetos.pluck(:id)

          # gather entity ids per type
          tarefa_ids = Tarefa.where(projeto_id: project_ids).pluck(:id)
          fluxo_ids = Fluxograma.where(projeto_id: project_ids).pluck(:id)
          arquivo_ids = Arquivo.where(projeto_id: project_ids).pluck(:id)
          link_ids = Link.where(projeto_id: project_ids).pluck(:id)
          evento_ids = Evento.where(projeto_id: project_ids).pluck(:id)

          entidade_conditions = Historico.none
          entidade_conditions = entidade_conditions.or(Historico.where(entidade: :projeto, entidade_id: project_ids)) if project_ids.present?
          entidade_conditions = entidade_conditions.or(Historico.where(entidade: :tarefa, entidade_id: tarefa_ids)) if tarefa_ids.present?
          entidade_conditions = entidade_conditions.or(Historico.where(entidade: :fluxograma, entidade_id: fluxo_ids)) if fluxo_ids.present?
          entidade_conditions = entidade_conditions.or(Historico.where(entidade: :arquivo, entidade_id: arquivo_ids)) if arquivo_ids.present?
          entidade_conditions = entidade_conditions.or(Historico.where(entidade: :link, entidade_id: link_ids)) if link_ids.present?
          entidade_conditions = entidade_conditions.or(Historico.where(entidade: :evento, entidade_id: evento_ids)) if evento_ids.present?

          registros = registros.merge(entidade_conditions)
        end

        render_paginated(registros, HistoricoSerializer)
      end

      # GET /api/v1/historico/:id
      def show
        registro = Historico.find(params[:id])
        render_success(HistoricoSerializer.new(registro).as_json)
      end

      # GET /api/v1/historico/exportar
      def exportar
        registros = Historico.includes(:usuario).recentes
        
        # Aplicar mesmos filtros do index
        registros = registros.por_usuario(params[:usuarioId]) if params[:usuarioId].present?
        registros = registros.por_entidade(params[:entidade]) if params[:entidade].present?
        
        csv_data = HistoricoExportService.to_csv(registros)
        
        send_data csv_data,
                  filename: "historico_#{Date.current}.csv",
                  type: "text/csv"
      end
    end
  end
end
