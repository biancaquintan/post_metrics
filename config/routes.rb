Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      resources :posts, only: [ :create ] do
        collection do
          get :top_rated
          post :batch, action: :batch_create
        end
      end

      resources :ratings, only: [ :create ] do
        collection do
          post :batch, action: :batch_create
        end
      end

      get "posts/authors_ips_list", to: "posts#authors_ips_list"
    end
  end
end
