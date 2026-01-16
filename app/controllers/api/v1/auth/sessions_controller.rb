# frozen_string_literal: true

module Api
  module V1
    module Auth
      class SessionsController < ApplicationController
        skip_before_action :authenticate_request, only: [:create]

        # POST /api/v1/auth/login
        def create
          result = AuthService.login(
            email: params[:email],
            senha: params[:senha],
            ip: request.remote_ip
          )

          if result[:success]
            render_success(result[:data], "Login realizado com sucesso")
          else
            render_error(result[:error], :unauthorized)
          end
        end

        # GET /api/v1/auth/me
        def show
          render_success(
            UsuarioSerializer.new(current_user).as_json
          )
        end

        # DELETE /api/v1/auth/logout
        def destroy
          Historico.registrar!(
            acao: :logout,
            entidade: :usuario,
            entidade_id: current_user.id,
            entidade_nome: current_user.nome,
            usuario: current_user,
            ip: request.remote_ip
          )

          render_success(nil, "Logout realizado com sucesso")
        end
      end
    end
  end
end
