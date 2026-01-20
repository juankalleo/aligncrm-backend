# frozen_string_literal: true

module Api
  module V1
    class ProjetoMembrosController < ApplicationController
      before_action :set_projeto

      # POST /api/v1/projetos/:projeto_id/membros
      def create
        authorize @projeto

        # accept either usuarioId or usuario_id in payload
        uid = params[:usuarioId].presence || params[:usuario_id].presence || params.dig(:membro, :usuario_id)
        unless uid.present?
          return render_error('Usuário não informado', :bad_request)
        end

        usuario = Usuario.find_by(id: uid, ativo: true)
        unless usuario
          return render_error('Usuário não encontrado', :not_found)
        end

        @projeto.adicionar_membro(usuario)
        render_success(nil, 'Membro adicionado ao projeto')
      end

      # DELETE /api/v1/projetos/:projeto_id/membros/:id
      def destroy
        authorize @projeto
        uid = params[:id]
        usuario = Usuario.find_by(id: uid)
        unless usuario
          return render_error('Usuário não encontrado', :not_found)
        end

        @projeto.remover_membro(usuario)
        render_success(nil, 'Membro removido do projeto')
      end

      private

      def set_projeto
        @projeto = Projeto.find(params[:projeto_id])
      end
    end
  end
end
