# frozen_string_literal: true

module Api
  module V1
    class FluxogramasController < BaseController
      before_action :set_fluxograma, only: [:show, :update, :destroy, :exportar]
      before_action :set_projeto, only: [:index], if: -> { params[:projeto_id].present? }

      # GET /api/v1/fluxogramas
      # GET /api/v1/projetos/:projeto_id/fluxogramas
      # GET /api/v1/workspaces/:workspace_id/fluxogramas
      def index
        if @projeto
          # Fluxogramas de um projeto específico
          @fluxogramas = @projeto.fluxogramas.recentes
        elsif params[:workspace_id].present?
          workspace = ::Workspace.find(params[:workspace_id])
          projetos_ids = workspace.projetos.pluck(:id)
          @fluxogramas = Fluxograma.where(projeto_id: projetos_ids).recentes
        else
          # Fluxogramas acessíveis ao usuário (projetos do usuário)
          projetos_ids = Projeto.do_usuario(current_user).pluck(:id)
          @fluxogramas = Fluxograma.where(projeto_id: projetos_ids).recentes
        end

        serialized = @fluxogramas.map { |f| FluxogramaSerializer.new(f).as_json }
        render_success(serialized)
      end

      # GET /api/v1/fluxogramas/:id
      def show
        authorize_fluxograma!
        render_success(FluxogramaSerializer.new(@fluxograma).as_json)
      end

      # POST /api/v1/fluxogramas
      def create
        @fluxograma = Fluxograma.new(fluxograma_params)
        @fluxograma.criador = current_user

        if @fluxograma.save
          render_success(
            FluxogramaSerializer.new(@fluxograma).as_json,
            "Fluxograma criado com sucesso",
            :created
          )
        else
          render_error(@fluxograma.errors.full_messages.join(', '), :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/fluxogramas/:id
      def update
        authorize_fluxograma!

        if @fluxograma.update(fluxograma_params)
          render_success(
            FluxogramaSerializer.new(@fluxograma).as_json,
            "Fluxograma atualizado com sucesso"
          )
        else
          render_error(@fluxograma.errors.full_messages.join(', '), :unprocessable_entity)
        end
      end

      # DELETE /api/v1/fluxogramas/:id
      def destroy
        authorize_fluxograma!

        @fluxograma.destroy
        render_success(nil, "Fluxograma deletado com sucesso")
      end

      # GET /api/v1/fluxogramas/:id/exportar
      def exportar
        authorize_fluxograma!

        payload = @fluxograma.dados
        payload = payload.to_json unless payload.is_a?(String)
        send_data payload,
          filename: "#{@fluxograma.nome}.json",
          type: 'application/json'
      end

      private

      def set_fluxograma
        @fluxograma = Fluxograma.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error("Fluxograma não encontrado", :not_found)
      end

      def set_projeto
        @projeto = Projeto.find(params[:projeto_id])
      rescue ActiveRecord::RecordNotFound
        render_error("Projeto não encontrado", :not_found)
      end

      def authorize_fluxograma!
        unless current_user.admin? || @fluxograma.projeto.membros.include?(current_user) || @fluxograma.criador == current_user
          render_error("Acesso negado", :forbidden)
        end
      end

      def fluxograma_params
        # support both top-level params and nested `fluxograma` payloads
        source = params[:fluxograma].present? ? params.require(:fluxograma).permit! : params

        # permit `dados` as a permissive JSON/hash so Excalidraw payload is accepted
        permitted = source.permit(:nome, :descricao, :projeto_id, dados: {})

        permitted
      end
    end
  end
end
