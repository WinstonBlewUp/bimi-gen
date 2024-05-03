require 'sidekiq/web'
Rails.application.routes.draw do

  # Root path set to logos new page
  #root to: redirect('/views/logos/new.html.erb')
  #get '/views/logos/new', to: 'pages#new'
  mount Sidekiq::Web => '/sidekiq'

  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get 'emails/starred', to: 'emails#starred', as: 'starred_emails'
  get 'emails/:message_id/attachments/:attachment_id', to: 'emails#download_attachment', as: 'download_attachment'

  resources :logos, only: [:index, :new, :create, :show]
  resources :emails, only: [:index, :new, :create, :destroy, :show]
  resources :contacts, only: [:index, :create]
end