require 'sidekiq/web'
Rails.application.routes.draw do

  # Root path set to logos new page
  #root to: redirect('/views/logos/new.html.erb')
  #get '/views/logos/new', to: 'pages#new'

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  resources :logos, only: [:index, :new, :create, :show]
end