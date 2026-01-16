# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Pundit::Authorization

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

  # Response helpers
  def render_success(data = nil, message = nil, status = :ok)
    response = { sucesso: true }
    response[:dados] = data if data
    response[:mensagem] = message if message
    render json: response, status: status
  end

  def render_error(message, status = :unprocessable_entity, errors = nil)
    response = {
      sucesso: false,
      mensagem: message
    }
    response[:erros] = errors if errors
    render json: response, status: status
  end

  def render_paginated(records, serializer = nil)
    paginated = records.page(params[:pagina] || 1).per(params[:porPagina] || 20)
    
    data = if serializer
             ActiveModelSerializers::SerializableResource.new(paginated, each_serializer: serializer)
           else
             paginated
           end

    render json: {
      sucesso: true,
      dados: data,
      meta: {
        total: paginated.total_count,
        pagina: paginated.current_page,
        porPagina: paginated.limit_value,
        totalPaginas: paginated.total_pages
      }
    }
  end

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
