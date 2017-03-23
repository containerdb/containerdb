Rails.application.routes.draw do

  root to: redirect('/services')

  resources :services do
    collection do
      get :choose
    end
  end
end
