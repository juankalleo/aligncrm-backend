# Auth Controller - Registro, Login, Logout

module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [:login, :register]
      
      # POST /api/v1/auth/login
      def login
        usuario = Usuario.find_by(email: auth_params[:email])
        Rails.logger.info("Auth attempt: email=#{auth_params[:email]}, user_found=#{!usuario.nil?}")
        
        if usuario&.authenticate(auth_params[:password])
          token = AuthService.generate_token(usuario)
          render_success({
            usuario: UsuarioSerializer.new(usuario).as_json,
            token: token,
            expires_in: 7.days.from_now
          })
        else
          render_error("E-mail ou senha inválidos", :unauthorized)
        end
      end
      
      # POST /api/v1/auth/register
      def register
        usuario = Usuario.new(register_params)
        
        if usuario.save
          token = AuthService.generate_token(usuario)
          render_success({
            usuario: UsuarioSerializer.new(usuario).as_json,
            token: token
          }, :created)
        else
          render_errors(usuario.errors.full_messages)
        end
      end
      
      # POST /api/v1/auth/logout
      def logout
        # JWT é stateless, logout é apenas no frontend
        render_success({ message: "Logout realizado com sucesso" })
      end
      
      # GET /api/v1/auth/me
      def me
        render_success(UsuarioSerializer.new(current_user).as_json)
      end
      
      private
      
      def auth_params
        params.require(:auth).permit(:email, :password)
      end
      
      def register_params
        params.require(:usuario).permit(:nome, :email, :password, :password_confirmation)
      end
    end
  end
end
