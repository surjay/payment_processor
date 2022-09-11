Rails.application.routes.draw do
  namespace :v1 do
    resources :merchants do
      resources :payment_methods
      resources :transactions
    end
    resources :transaction_audits, only: :index
    resources :payout_audits, only: :index
  end
end
