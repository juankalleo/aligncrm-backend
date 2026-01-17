# Align CRM - Rotas da API
# Todas as rotas seguem o padrão REST com versionamento

Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "login", to: "sessions#create"
        post "register", to: "registrations#create"
        delete "logout", to: "sessions#destroy"
        get "me", to: "sessions#show"
        patch "profile", to: "profile#update"
        patch "password", to: "password#update"
        post "forgot-password", to: "password#forgot"
        post "reset-password", to: "password#reset"
      end

      resources :projetos do
        collection do
          post 'reordenar'
        end

        resources :tarefas, only: [:index] do
          collection do
            post 'arquivar_concluidas'
          end
        end

        resources :fluxogramas, only: [:index]
        resources :eventos, only: [:index]

        resources :solicitacoes, only: [:index, :create, :show, :update], controller: "projeto_solicitacoes"
        post 'solicitacoes', to: 'projeto_solicitacoes#create_by_code', on: :collection

        resources :membros, only: [:create, :destroy], controller: "projeto_membros"
        get "estatisticas", on: :member
        get "historico", on: :member
      end

      resources :workspaces, only: [:index, :show, :create, :update] do
        get 'projetos', to: 'workspaces#projetos', on: :member
        get 'usuarios', to: 'workspaces#usuarios', on: :member
        # List tasks for a workspace (handled by TarefasController#index)
        get 'tarefas', to: 'tarefas#index', on: :member
        post 'tarefas/arquivar_concluidas', to: 'tarefas#arquivar_concluidas', on: :member
        # Workspace-scoped historico (delegates to HistoricoController#index with workspace_id)
        get 'historico', to: 'historico#index', on: :member
        get 'historico/exportar', to: 'historico#exportar', on: :member
        get 'solicitacoes', to: 'workspaces#solicitacoes', on: :member
        delete 'usuarios/:usuario_id', to: 'workspaces#remover_usuario', on: :member
        post 'invites', to: 'workspace_invites#create', on: :member
        # Workspace-scoped events
        get 'eventos', to: 'eventos#index', on: :member
        post 'eventos', to: 'eventos#create', on: :member
      end

      # Public invite acceptance/validation
      get 'invites/:token', to: 'workspace_invites#show'
      post 'invites/:token/accept', to: 'workspace_invites#accept'

      resources :fluxogramas, only: [:index]
      resources :eventos, only: [:index, :create]

      resources :historico, only: [:index] do
        collection do
          get 'exportar'
        end
      end

      resources :arquivos, only: [:index, :create, :destroy] do
        get 'download', on: :member
      end

      resources :links, only: [:index, :create]

      resources :tarefas do
        patch "status", on: :member
        patch "reordenar", on: :member
        patch "atribuir", on: :member
        collection do
          get "minhas"
        end
      end

      resources :usuarios do
        patch "role", on: :member
        patch "desativar", on: :member
        patch "reativar", on: :member
        post "avatar", on: :member
        get "historico", on: :member
      end

      get 'solicitacoes/minhas', to: 'projeto_solicitacoes#minhas'

      resources :historico, only: [:index, :show] do
        collection do
          get "exportar"
        end
      end

      resources :fluxogramas do
        get "exportar", on: :member
      end

      resources :eventos do
        collection do
          post "exportar-ics"
          post "importar-ics"
        end
      end

      resources :arquivos, only: [:index, :create, :destroy] do
        get "download", on: :member
      end

      resources :links, only: [:index, :create, :update, :destroy]
      
      # Domain management
      resources :dominios do
        collection do
          get 'expirados_count'
        end
      end
      
      # VPS and credentials management
      resources :vps
      resources :financeiros
    end
  end
end
