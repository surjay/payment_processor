Rails.application.routes.draw do
  namespace :v1 do
    resources :merchants do
      resources :payment_methods
    end
  end
end
