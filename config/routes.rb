Rails.application.routes.draw do
  get 'airports/index'
  devise_for :users, controllers: {sessions: 'users/sessions', invitations: 'users/invitations'}

  resources :users, :only => [:show]
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/search", to: "itineraries#search"
  # Defines the root path route ("/")
  # root "articles#index"

  resources :bookings, only: [:edit, :update]

  resources :passenger_groups, only: [:show] do
    resources :bookings, only: [:new, :create]
  end

  resources :permissions, only: [:destroy]

  resources :itineraries, only: [:index, :show, :destroy] do
    resources :permissions, only: [:create]
  end
end
