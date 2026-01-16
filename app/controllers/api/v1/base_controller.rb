# API Base Controller

module Api
  module V1
    class BaseController < ApplicationController
      include ActionController::Serialization
      
      before_action :set_pagination
      
      protected
      
      def set_pagination
        @page = params[:page] || 1
        @per_page = params[:per_page] || 20
      end
      
      def paginate(relation)
        relation.page(@page).per(@per_page)
      end
    end
  end
end
