Rails.application.routes.draw do
  resources :services do
    collection do
      get :choose
    end
  end
end
