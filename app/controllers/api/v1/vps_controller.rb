# frozen_string_literal: true

module Api
  module V1
    class VpsController < ApplicationController
      before_action :set_vps, only: [:show, :update, :destroy]

      # GET /api/v1/vps
      def index
        vps = Vps.order(created_at: :desc)
        render_paginated(vps, VpsSerializer)
      end

      # GET /api/v1/vps/:id
      def show
        render_success(VpsSerializer.new(@vps).as_json)
      end

      # POST /api/v1/vps
      def create
        v = Vps.new(vps_params)
        v.created_by = current_user&.id if respond_to?(:current_user) && current_user

        # normalize projetos param if provided
        if params[:projetos].present?
          v.projetos = params[:projetos]
        end

        if v.save
          render_success(VpsSerializer.new(v).as_json, 'VPS criada', :created)
        else
          render_error('Erro ao criar VPS', :unprocessable_entity, v.errors.full_messages)
        end
      end

      # PATCH/PUT /api/v1/vps/:id
      def update
        if @vps.update(vps_params)
          # update projetos if passed
          @vps.update(projetos: params[:projetos]) if params.key?(:projetos)
          render_success(VpsSerializer.new(@vps).as_json, 'VPS atualizada')
        else
          render_error('Erro ao atualizar VPS', :unprocessable_entity, @vps.errors.full_messages)
        end
      end

      # DELETE /api/v1/vps/:id
      def destroy
        @vps.destroy
        render_success(nil, 'VPS removida')
      end

      private

      def set_vps
        @vps = Vps.find(params[:id])
      end

      def vps_params
        params.permit(:nome, :login_root, :senha_root, :email_relacionado, :storage_gb, :comprado_em, :comprado_em_local)
      end
    end
  end
end
