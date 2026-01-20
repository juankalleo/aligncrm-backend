module Api
  module V1
    class FinanceirosController < ApplicationController
      before_action :set_financeiro, only: [:show, :update, :destroy]

      # GET /api/v1/financeiros
      def index
        scope = Financeiro.all.order(created_at: :desc)
        scope = scope.where(projeto_id: params[:projeto_id]) if params[:projeto_id].present?
        render_paginated(scope, FinanceiroSerializer)
      end

      # GET /api/v1/financeiros/:id
      def show
        render_success(FinanceiroSerializer.new(@financeiro).as_json)
      end

      # POST /api/v1/financeiros
      def create
        f = Financeiro.new(financeiro_params)
        f.created_by = current_user&.id if respond_to?(:current_user) && current_user

        if f.save
          render_success(FinanceiroSerializer.new(f).as_json, 'Registro financeiro criado', :created)
        else
          render_error('Erro ao criar registro financeiro', :unprocessable_entity, f.errors.full_messages)
        end
      end

      # PATCH /api/v1/financeiros/:id
      def update
        if @financeiro.update(financeiro_params)
          render_success(FinanceiroSerializer.new(@financeiro).as_json, 'Registro financeiro atualizado')
        else
          render_error('Erro ao atualizar registro financeiro', :unprocessable_entity, @financeiro.errors.full_messages)
        end
      end

      # DELETE /api/v1/financeiros/:id
      def destroy
        @financeiro.destroy
        render_success(nil, 'Registro financeiro removido')
      end

      private

      def set_financeiro
        @financeiro = Financeiro.find(params[:id])
      end

      def financeiro_params
        allowed = %i[projeto_id categoria tipo descricao valor data pago vencimento]
        # only permit attributes that actually exist on the model (handles schema drift)
        permitted = allowed.select { |a| Financeiro.column_names.include?(a.to_s) }
        # permit only existing columns, and remove nil values to avoid assigning nulls
        filtered = params.permit(*permitted).to_h.reject { |_, v| v.nil? }
        ActionController::Parameters.new(filtered).permit(*permitted)
      end
    end
  end
end
