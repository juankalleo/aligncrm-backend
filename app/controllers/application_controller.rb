# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit::Authorization
  # Ensure the concern is loaded in production/preloaded environments
  require_dependency 'response_helpers'
  include ResponseHelpers

  before_action :authenticate_request
  
  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from JWT::DecodeError, with: :handle_invalid_token

  protected

  def authenticate_request
    @current_user = AuthService.authenticate(request.headers["Authorization"])
    render_error("Token inválido ou expirado", :unauthorized) unless @current_user
  end

  def current_user
    @current_user
  end

  # Response helpers provided by ResponseHelpers concern

  private

  def handle_unauthorized
    render_error("Acesso negado", :forbidden)
  end

  def handle_not_found
    render_error("Recurso não encontrado", :not_found)
  end

  def handle_invalid_record(exception)
    render_error(
      "Dados inválidos",
      :unprocessable_entity,
      exception.record.errors.full_messages
    )
  end

  def handle_invalid_token
    render_error("Token inválido", :unauthorized)
  end
end
