module ResponseHelpers
  extend ActiveSupport::Concern

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
end
