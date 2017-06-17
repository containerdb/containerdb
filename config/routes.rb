Rails.application.routes.draw do

  devise_for :users
  root to: redirect('/services')

  resources :users, only: [:index, :new, :create, :destroy]
  resources :machines

  resources :storage_providers do
    collection do
      get :choose
    end
  end

  resources :services do
    resources :backups, only: [:create]

    collection do
      get :choose
    end
  end
end
