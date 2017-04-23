Rails.application.routes.draw do

  devise_for :users
  root to: redirect('/services')

  resources :storage_providers do
    collection do
      get :choose
    end
  end

  resources :services do
    resources :backups

    collection do
      get :choose
    end
  end
end
