# frozen_string_literal: true

module Api
  module V1
    class UsuariosController < ApplicationController
      before_action :set_usuario, only: [:show, :update, :role, :desativar, :reativar, :avatar, :historico]
      before_action :authorize_admin, only: [:index, :create, :role, :desativar, :reativar]

      # GET /api/v1/usuarios
      def index
        usuarios = Usuario.includes(:projetos)
                         .por_nome

        render_paginated(usuarios, UsuarioSerializer)
      end

      # GET /api/v1/usuarios/:id
      def show
        authorize @usuario
        render_success(UsuarioSerializer.new(@usuario).as_json)
      end

      # POST /api/v1/usuarios
      def create
        @usuario = Usuario.new(usuario_params)
        # Accept password provided as :senha (Portuguese) or :password
        if params[:senha].present? && @usuario.password.blank?
          @usuario.password = params[:senha]
        elsif params[:password].present? && @usuario.password.blank?
          @usuario.password = params[:password]
        end

        if @usuario.save
          registrar_acao(:criar)
          render_success(
            UsuarioSerializer.new(@usuario).as_json,
            "Usuário criado com sucesso",
            :created
          )
        else
          render_error(
            "Erro ao criar usuário",
            :unprocessable_entity,
            @usuario.errors.full_messages
          )
        end
      end

      # PATCH /api/v1/usuarios/:id
      def update
        authorize @usuario

        # Allow updating password if provided (either :senha or :password)
        if params[:senha].present?
          @usuario.password = params[:senha]
        elsif params[:password].present?
          @usuario.password = params[:password]
        end

        if @usuario.update(usuario_update_params)
          registrar_acao(:atualizar)
          render_success(
            UsuarioSerializer.new(@usuario).as_json,
            "Usuário atualizado com sucesso"
          )
        else
          render_error(
            "Erro ao atualizar usuário",
            :unprocessable_entity,
            @usuario.errors.full_messages
          )
        end
      end

      # PATCH /api/v1/usuarios/:id/role
      def role
        old_role = @usuario.role
        
        if @usuario.update(role: params[:role])
          Historico.registrar!(
            acao: :permissao_alterada,
            entidade: :usuario,
            entidade_id: @usuario.id,
            entidade_nome: @usuario.nome,
            usuario: current_user,
            detalhes: { role_anterior: old_role, role_novo: @usuario.role },
            ip: request.remote_ip
          )
          
          render_success(
            UsuarioSerializer.new(@usuario).as_json,
            "Permissão alterada com sucesso"
          )
        else
          render_error("Erro ao alterar permissão", :unprocessable_entity)
        end
      end

      # PATCH /api/v1/usuarios/:id/desativar
      def desativar
        if @usuario.update(ativo: false)
          render_success(nil, "Usuário desativado com sucesso")
        else
          render_error("Erro ao desativar usuário", :unprocessable_entity)
        end
      end

      # PATCH /api/v1/usuarios/:id/reativar
      def reativar
        if @usuario.update(ativo: true)
          render_success(nil, "Usuário reativado com sucesso")
        else
          render_error("Erro ao reativar usuário", :unprocessable_entity)
        end
      end

      # POST /api/v1/usuarios/:id/avatar
      def avatar
        authorize @usuario

        if params[:avatar].present?
          @usuario.avatar.attach(params[:avatar])
          
          render_success(
            { url: @usuario.avatar.url },
            "Avatar atualizado com sucesso"
          )
        else
          render_error("Arquivo não enviado", :unprocessable_entity)
        end
      end

      # GET /api/v1/usuarios/:id/historico
      def historico
        authorize @usuario

        registros = Historico.por_usuario(@usuario.id)
                            .includes(:usuario)
                            .recentes

        render_paginated(registros, HistoricoSerializer)
      end

      private

      def set_usuario
        @usuario = Usuario.find(params[:id])
      end

      def usuario_params
        params.permit(:nome, :email, :senha, :role)
      end

      def usuario_update_params
        params.permit(:nome, :email)
      end

      def authorize_admin
        render_error("Acesso negado", :forbidden) unless current_user.admin?
      end

      def registrar_acao(acao)
        Historico.registrar!(
          acao: acao,
          entidade: :usuario,
          entidade_id: @usuario.id,
          entidade_nome: @usuario.nome,
          usuario: current_user,
          ip: request.remote_ip
        )
      end
    end
  end
end
