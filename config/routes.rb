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
  get    '/attendances/:id/salary_management',  to: 'attendances#salary_management', as: 'attendances_salary_management'
  
  resources :users do
    resources :attendances
  end
  resources :shifts
end