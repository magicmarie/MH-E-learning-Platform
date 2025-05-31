Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Auth
  post "/signup", to: "auth#signup"
  post "/login", to: "auth#login"
  post "login", to: "auth#login"
  post "login/security", to: "auth#verify_security"

  # Org Admin — manage users within their org
  resource :organization, only: [ :show, :update ]
  resources :users, only: [ :create, :index ] do
    member do
      patch :activate # PATCH /users/:id/activate
      patch :deactivate # PATCH /users/:id/deactivate
      get :profile # GET /users/:id/profile
      get :organization # GET /users/:id/organization
    end
  end

  # Global Admin — manage orgs and org_admins
  namespace :admin do
    resources :organizations, only: [ :index, :create, :show, :update, :destroy ]

    resources :users, only: [ :create, :index ] do
      member do
        patch :activate
        patch :deactivate
        get :profile
        get :organization
      end
    end
  end
end
