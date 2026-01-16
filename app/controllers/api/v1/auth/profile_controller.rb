# frozen_string_literal: true

module Api
  module V1
    module Auth
      class ProfileController < ApplicationController
        # PATCH /api/v1/auth/profile
        def update
          if current_user.update(profile_params)
            render_success(
              UsuarioSerializer.new(current_user).as_json,
              "Perfil atualizado com sucesso"
            )
          else
            render_error(
              "Erro ao atualizar perfil",
              :unprocessable_entity,
              current_user.errors.full_messages
            )
          end
        end

        private

        def profile_params
          params.permit(:nome, :avatar, preferencias: {})
        end
      end
    end
  end
end
