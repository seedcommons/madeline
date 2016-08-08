Rails.application.routes.draw do
  devise_for :users, skip: [:registrations] # Disallow registration
  devise_scope :user do
    # Manually re-creates routes for editing users
    get 'users/edit' => 'devise/registrations#edit', as: :edit_user_registration
    put 'users' => 'devise/registrations#update', as: :user_registration
  end

  namespace :admin do
    resources :calendar, only: [:index]
    resources :calendar_events, only: [:index]
    resources :loan_response_sets
    resources :dashboard, only: [:index]
    resources :divisions do
      collection do
        post :select
      end
    end
    resources :loans do
      member do
        get :steps
        get :questionnaires
        patch :change_date
        get :print
      end
    end
    resources :loan_questions, as: :custom_fields do
      patch 'move', on: :member
    end
    resources :organizations
    resources :people
    resources :project_logs
    resources :project_steps do
      collection do
        patch :batch_destroy
        patch :adjust_dates
        patch :finalize
      end
      member do
        post :duplicate
        patch :shift_subsequent
      end
    end
    resources :project_step_moves

    scope '/:attachable_type/:attachable_id' do
      resources :media
    end

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
      resources :loan_response_sets
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
