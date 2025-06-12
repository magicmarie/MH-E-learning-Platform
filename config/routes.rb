Rails.application.routes.draw do
  resources :courses
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  require "sidekiq/web"

  if Rails.env.development? || Rails.env.test?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
    mount Sidekiq::Web => "/sidekiq"
  end

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic, "Protected Area" do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, ENV["SIDEKIQ_USER"]) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV["SIDEKIQ_PASSWORD"])
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  # Auth
  post "/signup", to: "auth#signup"
  post "/login", to: "auth#login"
  post "/login/security", to: "auth#verify_security"
  get "/organizations/search", to: "organizations#search"
  get "/organizations", to: "organizations#index"
  post "/password/change", to: "auth#change_password"

  resources :profiles, only: [ :show, :update, :destroy ]
  # GET /profiles/:id
  # PATCH /profiles/:id
  # DELETE /profiles/:id

  resources :students, only: [ :index, :show ]
  # GET /students
  # GET /students/:id

  resources :users, only: [ :create, :index, :update ] do
    member do
      patch :activate # PATCH /users/:id/activate
      patch :deactivate # PATCH /users/:id/deactivate
      get :organization # GET /users/:id/organization
    end
  end

  # Org Admin — manage users within their org
  resource :organization, only: [ :show, :update ]
  # GET /organization
  # PATCH /organization

  # Global Admin — manage everything
  namespace :admin do
    get "organizations/stats", to: "organizations#index_stats" # GET /admin/organizations/stats

    resources :organizations, only: [ :index, :create, :show, :update, :destroy ]
    # GET /admin/organizations
    # POST /admin/organizations
    # GET /admin/organizations/:id
    # PATCH /admin/organizations/:id
    # DELETE /admin/organizations/:id

    resources :users, only: [ :create, :index, :update ] do
      member do
        patch :activate # PATCH /admin/users/:id/activate
        patch :deactivate # PATCH /admin/users/:id/deactivate
        get :organization # GET /admin/users/:id/organization
      end
    end

    resources :courses, only: [ :index, :create, :update, :destroy, :show ] do
      # GET /admin/courses
      # POST /admin/courses
      # GET /admin/courses/:id
      # PATCH /admin/courses/:id
      # DELETE /admin/courses/:id

      post "enrollments/bulk", to: "enrollments#bulk_create"
      resources :enrollments, only: [ :index, :create, :update, :destroy, :show ]
      # GET /admin/courses/:course_id/enrollments
      # GET /admin/courses/:course_id/enrollments/:id
      # POST /admin/courses/:course_id/enrollments
      # PATCH /admin/courses/:course_id/enrollments/:id
      # DELETE /admin/courses/:course_id/enrollments/:id

      resources :assignments, only: [ :index, :create, :update, :destroy, :show ]
      # GET /admin/courses/:course_id/assignments
      # GET /admin/courses/:course_id/assignments/:id
      # POST /admin/courses/:course_id/assignments
      # PATCH /admin/courses/:course_id/assignments/:id
      # DELETE /admin/courses/:course_id/assignments/:id

      resources :assessments, only: [ :index, :create, :update, :show ]
      # GET /admin/courses/:course_id/assessments
      # POST /admin/courses/:course_id/assessments
      # GET /admin/courses/:course_id/assessments/:id
      # PATCH /admin/courses/:course_id/assessments/:id
    end
  end

  # Global Admin || Org Admin || Teacher
  resources :courses do
    # GET /courses
    # POST /courses
    # GET /courses/:id
    # PATCH /courses/:id
    # DELETE /courses/:id

    get "students/enrolled", to: "students#enrolled"
    get "students/unenrolled", to: "students#unenrolled"
    post "enrollments/bulk", to: "enrollments#bulk_create"

    resources :resources, only: [ :index, :create, :update, :destroy, :show ]
    # GET /courses/:course_id/resources
    # GET /courses/:course_id/resources/:id
    # POST /courses/:course_id/resources
    # PATCH /courses/:course_id/resources/:id
    # DELETE /courses/:course_id/resources/:id

    resources :enrollments, only: [ :index, :create, :update, :destroy, :show ]
    # GET /courses/:course_id/enrollments
    # GET /courses/:course_id/enrollments/:id
    # POST /courses/:course_id/enrollments
    # PATCH /courses/:course_id/enrollments/:id
    # DELETE /courses/:course_id/enrollments/:id

    resources :assignments, only: [ :index, :create, :update, :destroy, :show ]
    # GET /courses/:course_id/assignments
    # GET /courses/:course_id/assignments/:id
    # POST /courses/:course_id/assignments
    # PATCH /courses/:course_id/assignments/:id
    # DELETE /courses/:course_id/assignments/:id

    resources :assessments, only: [ :index, :create, :update, :show ]
    # GET /courses/:course_id/assessments
    # POST /courses/:course_id/assessments
    # GET /courses/:course_id/assessments/:id
    # PATCH /courses/:course_id/assessments/:id
  end
end
