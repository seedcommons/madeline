Rails.application.routes.draw do
  devise_for :users, skip: [:registrations] # Disallow registration
  devise_scope :user do
    # Manually re-creates routes for editing users
    get 'users/edit' => 'devise/registrations#edit', as: :edit_user_registration
    put 'users' => 'devise/registrations#update', as: :user_registration
  end

  namespace :admin do
    resources :dashboard, only: [:index]
    resources :calendar, only: [:index]

    namespace :raw do
      resources :divisions
      resources :loans
      resources :organizations
      resources :people
      resources :organization_snapshots
      resources :project_steps
      resources :project_logs
      resources :notes
      post 'select_division', to: 'divisions#select'
    end
  end

  localized do
    resources :loans, only: [:index, :show]
    get 'loans/:id/gallery', to: 'loans#gallery', as: :gallery
  end

  root to: 'admin/dashboard#index'
end
