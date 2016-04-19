Rails.application.routes.draw do
  devise_for :users, skip: [:registrations] # Disallow registration
  devise_scope :user do
    # Manually re-creates routes for editing users
    get 'users/edit' => 'devise/registrations#edit', as: :edit_user_registration
    put 'users' => 'devise/registrations#update', as: :user_registration
  end

  namespace :admin do
    resources :calendar, only: [:index]
    resources :dashboard, only: [:index]
    resources :loans
    resources :organizations
    resources :project_steps do
      collection do
        delete '', to: 'project_steps#batch_destroy'
        patch 'adjust_dates', to: 'project_steps#adjust_dates'
        patch 'finalize', to: 'project_steps#finalize'
      end
    end
    resources :project_logs

    namespace :raw do
      resources :divisions
      resources :loans
      resources :organizations
      resources :people
      resources :organization_snapshots
      resources :project_steps
      resources :project_logs
      resources :notes
      resources :custom_field_sets
      resources :custom_fields
      resources :custom_value_sets
      post 'select_division', to: 'divisions#select'
    end
  end

  localized do
    resources :loans, only: [:index, :show]
    get 'loans/:id/gallery', to: 'loans#gallery', as: :gallery
  end

  get '/test' => 'static_pages#test'

  root to: 'admin/dashboard#index'
end
