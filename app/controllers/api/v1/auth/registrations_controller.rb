# frozen_string_literal: true

module Api
  module V1
    module Auth
      class RegistrationsController < ApplicationController
        skip_before_action :authenticate_request

        # POST /api/v1/auth/register
        def create
          result = AuthService.register(
            nome: params[:nome],
            email: params[:email],
            senha: params[:senha],
            ip: request.remote_ip
          )

          if result[:success]
            render_success(result[:data], "Conta criada com sucesso", :created)
          else
            render_error(result[:error], :unprocessable_entity, result[:errors])
          end
        end
      end
    end
  end
end
