Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # API v1 routes
  namespace :api do
    namespace :v1 do
      resources :reconciliations, only: [:index, :show, :create]
    end
  end
end
