# frozen_string_literal: true

require 'sidekiq/web'
require "sidekiq/throttled/web"

Rails.application.routes.draw do
  # Replace Sidekiq Queues with enhanced version!
  Sidekiq::Throttled::Web.enhance_queues_tab!

  devise_for :admin_users, skip: [:registrations]
  ActiveAdmin.routes(self)

  authenticate :admin_user do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :skip => [:registrations], controllers: {
    sessions: "users/sessions"
  }
  devise_scope :user do
    # we've disabled registrations to avoid sign ups, but we still want editable users
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'

    get 'users/sign_in_with_token', to: 'users/sessions#sign_in_with_token'
    get 'magic-authentication', to: "users/sessions#sign_in_with_magic_token"
    namespace :users do
      resources :magic_links, only: [:create]
    end
  end

  devise_for :conservateurs, only: [:sessions, :passwords]
  devise_scope :conservateur do
    # we've disabled registrations to avoid sign ups, but we still want editable conservateurs
    get 'conservateurs/edit' => 'devise/registrations#edit', :as => 'edit_conservateur_registration'
  end

  root "pages#home"
  get "/stats", to: "pages#stats"
  get "/presse", to: "pages#presse"
  get "/conditions", to: "pages#cgu"
  get "/mentions_legales", to: "pages#mentions_legales"
  get "/confidentialite", to: "pages#confidentialite"
  get "comment-ca-marche", to: "pages#aide", as: "aide"
  get "guide-de-recensement", to: "pages#guide", as: "guide"
  get "/fiches", to: "pages#fiches"
  get "/fiche", to: "pages#pdf_embed"
  get "/pdf", to: "pages#pdf_download", as: "pdf_download"
  get "/connexion", to: "pages#connexion", as: "connexion"
  get "/admin", to: "pages#admin", as: "admin"

  resources :objets, only: [:index, :show]
  get "objets/ref_pop/:palissy_REF", to: "objets#show_by_ref_pop"

  resources :communes, only: [] do
    resource :completion, only: [:new, :create, :show], controller: "communes/completions"
    resource :recompletion, only: [:new, :create], controller: "communes/recompletions"
    resources :objets, only: [:index, :show], controller: "communes/objets" do
      resources :recensements, except: [:index, :show, :destroy], controller: "communes/recensements"
    end
    resource :formulaire, only: [:show], controller: "communes/formulaires"
    resources :dossiers, only: [:show], controller: "communes/dossiers"
    resources :campaign_recipients, only: [:update], controller: "communes/campaign_recipients"
  end

  resources :departements, only: [:index, :show]

  namespace :conservateurs do
    resources :departements, only: [:index, :show] do
      resources :communes, only: [:index]
    end
    resources :communes, only: [:show] do
      collection do
        post :autocomplete
      end
    end
    resources :objets, only: [] do
      resources :recensements, only: [] do
        resource :analyse, only: [:edit, :update]
      end
    end
    resources :dossiers, only: [:show] do
      resource :accept, only: [:new, :create, :update]
      resource :reject, only: [:new, :create, :update]
    end
  end

  namespace :admin do
    resources :communes, only: [:index, :show]
    resources :conservateurs, except: [:destroy] do |conservateur|
      get :impersonate
      collection do
        post :stop_impersonating
        post :toggle_impersonate_mode
      end
    end
    resources :dossiers, only: [:update]
    resources :users, only: [] do
      get :impersonate
      collection do
        post :stop_impersonating
        post :toggle_impersonate_mode
      end
    end
    resources :campaigns do
      get :show_statistics
      get :edit_recipients
      patch :update_recipients
      patch :update_status
      get :mail_previews
      if Rails.configuration.x.environment_specific_name != "production"
        post :force_start
        post :force_step_up
      end
      post :refresh_delivery_infos
      post :refresh_stats
      resources :recipients, controller: "campaign_recipients", only: [:show, :update] do
        get :mail_preview
      end
      resources :emails, controller: "campaign_emails", only: [] do
        get :redirect_to_sib_preview
      end
    end
    resources :active_admin_comments, only: [:create, :destroy], controller: "comments"
    resources :exports, only: [:index]
    resources :palissy_exports, only: [:new, :create]
    resources :memoire_exports, only: [:new, :create, :show]
    resources :attachments, only: [] do
      post :rotate
    end
  end
  get '/admin', to: redirect('/admin/communes')

  get "health/raise_on_purpose", to: "health#raise_on_purpose"
  get "health/js_error", to: "health#js_error"

  if Rails.env.development?
    get "health/slow_image", to: "health#slow_image", as: "slow_image"
    mount Lookbook::Engine, at: "/lookbook"
  end

  if Rails.configuration.x.environment_specific_name != "production"
    resources :mail_previews, only: [:index]
  end
end
