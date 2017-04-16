Rails.application.routes.draw do

  devise_for :users
  root to: redirect('/services')

  resources :services do
    resources :backups

    collection do
      get :choose
    end
  end
end
