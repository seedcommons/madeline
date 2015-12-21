Rails.application.routes.draw do
  devise_for :users

  localized do
    resources :loans, only: [:index, :show]
    get 'loans/:id/gallery', to: 'loans#gallery', as: :gallery
  end

  root to: 'loans#index'
end
