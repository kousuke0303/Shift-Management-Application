Rails.application.routes.draw do

  get 'sessions/new'

  root 'attendances#register'
  get '/signup', to: 'users#new'
  
  get    '/login', to: 'sessions#new'
  post   '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get    '/users/:id/attendances/register',  to: 'attendances#register', as: 'users_attendances_register'
  patch  '/users/:id/attendances/breakstart',  to: 'attendances#breakstart', as: 'users_attendances_breakstart'
  patch  '/users/:id/attendances/breakend',  to: 'attendances#breakend', as: 'users_attendances_breakend'
  get    '/users/:id/attendances/salary_management',  to: 'attendances#salary_management', as: 'users_attendances_salary_management'

  resources :users do
    member do
      get 'shifts/apply_next_shifts'
      patch 'shifts/update_next_shifts'
      get 'shifts/applying_next_shifts'
      patch 'shifts/confirm_next_shifts'
    end
    resources :shifts, only: :update
    resources :attendances
  end
end
