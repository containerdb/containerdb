Rails.application.routes.draw do

  devise_for :users
  root to: redirect('/services')

  resources :users, only: [:index, :new, :create, :destroy]

  resources :storage_providers do
    collection do
      get :choose
    end
  end

  resources :services do
    resources :backups, only: [:create, :destroy]

    collection do
      get :choose
    end
  end
end
