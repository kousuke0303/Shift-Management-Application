Rails.application.routes.draw do

  get 'sessions/new'

  root 'static_pages#top'
  get '/signup', to: 'users#new'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do
    member do
      get 'shifts/apply_next_shifts'
      patch 'shifts/update_next_shifts'
      get 'shifts/confirm_next_shifts'
    end
    resources :shifts, only: :update
  end
end
