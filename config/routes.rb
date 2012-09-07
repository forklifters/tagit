TagitRails::Application.routes.draw do
  resources :sessions, only: [:new, :create, :destroy]
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :posts
  resources :tags, :only => [:index, :show, :destroy]
  
  resources :relationships, only: [:create, :destroy]
  resources :post_tags, :only => [:create, :destroy]
  
  root to: "pages#home"
  match "/home", to: "pages#home"
  match "/signup",  to: "users#new"
  match "/signin",  to: "sessions#new"
  match "/signout", to: "sessions#destroy", via: :delete
end
