# frozen_string_literal: true

module Api
  module V1
    class EventosController < ApplicationController
      # GET /api/v1/eventos or /api/v1/projetos/:projeto_id/eventos or /api/v1/workspaces/:workspace_id/eventos
      def index
        eventos = Evento.all

        # support nested route /projetos/:projeto_id/eventos
        if params[:projeto_id].present?
          eventos = eventos.where(projeto_id: params[:projeto_id])
        elsif params[:workspace_id].present?
          workspace = ::Workspace.find(params[:workspace_id])
          projetos_ids = workspace.projetos.pluck(:id)
          eventos = eventos.where(projeto_id: projetos_ids)
        end

        # support both formats: nested hash params[:dataInicio][data_inicio]
        inicio_param = nil
        fim_param = nil

        # only treat as nested hash when it's a params/hash-like object
        if params[:dataInicio].respond_to?(:key?)
          inicio_param = params[:dataInicio][:data_inicio] || params[:dataInicio]['data_inicio']
          fim_param = params[:dataInicio][:data_fim] || params[:dataInicio]['data_fim']
        end

        inicio_param ||= params[:dataInicio] || params[:data_inicio]
        fim_param ||= params[:dataFim] || params[:data_fim]

        if inicio_param.present? && fim_param.present?
          begin
            inicio = Time.zone.parse(inicio_param.to_s).beginning_of_day
            fim = Time.zone.parse(fim_param.to_s).end_of_day
            eventos = eventos.where(data_inicio: inicio..fim)
          rescue StandardError
            # ignore parse errors and return unfiltered
          end
        end

        eventos = eventos.order(:data_inicio)

        render_success(eventos.as_json)
      end

      # GET /api/v1/eventos/:id
      def show
        evento = Evento.find(params[:id])
        render_success(evento.as_json)
      end

      # POST /api/v1/eventos or /api/v1/workspaces/:workspace_id/eventos
      def create
        params_hash = evento_params
        
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
        
        evento = Evento.new(params_hash)
        evento.criador = current_user

        if evento.save
          render_success(evento.as_json, 'Evento criado com sucesso', :created)
        else
          render_error('Erro ao criar evento', :unprocessable_entity, evento.errors.full_messages)
        end
      end

      # PATCH /api/v1/eventos/:id
      def update
        evento = Evento.find(params[:id])
        if evento.update(evento_params)
          render_success(evento.as_json, 'Evento atualizado com sucesso')
        else
          render_error('Erro ao atualizar evento', :unprocessable_entity, evento.errors.full_messages)
        end
      end

      # DELETE /api/v1/eventos/:id
      def destroy
        evento = Evento.find(params[:id])
        evento.destroy
        render_success(nil, 'Evento excluído com sucesso')
      end

      # POST /api/v1/eventos/exportar-ics
      def exportar_ics
        # minimal implementation: return not implemented
        render_error('Exportar ICS não implementado', :not_implemented)
      end

      # POST /api/v1/eventos/importar-ics
      def importar_ics
        render_error('Importar ICS não implementado', :not_implemented)
      end

      private

      def evento_params
        # Accept both wrapped (params[:evento]) and unwrapped formats
        source = params[:evento].present? ? params.require(:evento) : params
        permitted = source.permit(
          :titulo, :descricao, :tipo, :data_inicio, :data_fim, :dia_inteiro, 
          :projeto_id, :projetoId, :localizacao, :local, :link_reuniao, :cor, :lembrete
        )
        
        # Normalize field names
        if permitted[:projetoId].present? && permitted[:projeto_id].blank?
          permitted[:projeto_id] = permitted.delete(:projetoId)
        end
        if permitted[:local].present? && permitted[:localizacao].blank?
          permitted[:localizacao] = permitted.delete(:local)
        end
        
        permitted
      end
    end
  end
end
