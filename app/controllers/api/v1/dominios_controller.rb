# frozen_string_literal: true

module Api
  module V1
    class DominiosController < ApplicationController
      before_action :set_dominio, only: [:show, :update, :destroy]

      # GET /api/v1/dominios
      def index
        dominios = Dominio.order(expires_at: :asc)
        render_paginated(dominios, DominioSerializer)
      end

      # GET /api/v1/dominios/:id
      def show
        render_success(DominioSerializer.new(@dominio).as_json)
      end

      # GET /api/v1/dominios/expirados_count
      def expirados_count
        count = Dominio.expired.count
        render_success({ count: count })
      end

      # POST /api/v1/dominios
      def create
        dominio = Dominio.new(dominio_params)
        dominio.created_by = current_user&.id if respond_to?(:current_user) && current_user

        if dominio.save
          render_success(DominioSerializer.new(dominio).as_json, 'Domínio criado', :created)
        else
          render_error('Erro ao criar domínio', :unprocessable_entity, dominio.errors.full_messages)
        end
      end

      # PATCH/PUT /api/v1/dominios/:id
      def update
        if @dominio.update(dominio_params)
          render_success(DominioSerializer.new(@dominio).as_json, 'Domínio atualizado')
        else
          render_error('Erro ao atualizar domínio', :unprocessable_entity, @dominio.errors.full_messages)
        end
      end

      # DELETE /api/v1/dominios/:id
      def destroy
        @dominio.destroy
        render_success(nil, 'Domínio removido')
      end

      private

      def set_dominio
        @dominio = Dominio.find(params[:id])
      end

      def dominio_params
        params.permit(:nome, :porta, :nginx_server, :expires_at, :notified)
      end
    end
  end
end
