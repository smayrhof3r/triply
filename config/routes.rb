Rails.application.routes.draw do
  get 'airports/index'
  devise_for :users, controllers: {sessions: 'users/sessions'}

  resources :users, :only => [:show]
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/search", to: "itineraries#search"
  get "/search_index", to: "itineraries#search_index"

  # Defines the root path route ("/")
  # root "articles#index"

  resources :passenger_groups, only: [:show] do
    resources :bookings, only: [:new, :create]
  end

  resources :itineraries, only: [:index, :show] do
    resources :permissions, only: [:create]
  end
end
