Rails.application.routes.draw do
  get 'airports/index'
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "/search", to: "itineraries#search"
  get "/show", to: "itineraries#show"
  # Defines the root path route ("/")
  # root "articles#index"
  resources :itineraries, only: [:index, :show]
end
