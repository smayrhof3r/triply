Rails.application.routes.draw do
  get 'airports/index'
  devise_for :users, controllers: {sessions: 'users/sessions'}

  resources :users, :only => [:show]
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/search", to: "itineraries#search"
  # Defines the root path route ("/")
  # root "articles#index"

  resources :itineraries, only: [:index, :show] do
    resources :permissions, only: [:create]
  end
end
