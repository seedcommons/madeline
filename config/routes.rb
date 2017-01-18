Rails.application.routes.draw do
  # Disallow registration, wire up custom devise sessions controller
  devise_for :users, skip: [:registrations], controllers: { sessions: :sessions }

  devise_scope :user do
    # Manually re-creates routes for editing users
    get 'users/edit' => 'devise/registrations#edit', as: :edit_user_registration
    put 'users' => 'devise/registrations#update', as: :user_registration
  end

  namespace :admin do
    resources :basic_projects, path: 'projects'
    resources :calendar, only: [:index]
    resources :calendar_events, only: [:index]
    resources :loan_response_sets
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
        get :timeline
      end
    end
    resources :loan_questions do
      patch 'move', on: :member
    end
    resources :notes, only: [:create, :update, :destroy]
    resources :organizations
    resources :people
    resources :project_logs, path: 'logs'
    resources :project_steps do
      collection do
        patch :batch_destroy
        patch :adjust_dates
        patch :finalize
      end
      member do
        post :duplicate
        get :show_duplicate
      end
    end
    resources :project_groups

    resources :timeline_step_moves do
      member do
        patch :simple_move
      end
    end

    scope '/:attachable_type/:attachable_id' do
      resources :media
    end

    namespace :raw do
      resources :divisions
      resources :loans
      resources :organizations
      resources :people
      resources :project_steps
      resources :project_logs
      resources :notes
      resources :loan_question_sets
      resources :loan_questions
      resources :loan_response_sets
      post 'select_division', to: 'divisions#select'
    end

    get '/loans/:id/:tab' => 'loans#show', as: 'loan_tab'
  end

  localized do
    resources :loans, only: [:index, :show]
    get 'loans/:id/gallery', to: 'loans#gallery', as: :gallery
  end

  get '/test' => 'static_pages#test'

  root to: redirect('/admin/loans')
end
