API::Application.routes.draw do

  root :to => "home#index"

  devise_for :users, :controllers => {:registrations => "registrations",
                                      :omniauth_callbacks => "omniauth_callbacks",
                                      :sessions => "sessions"}





  get '/projects',        to: 'projects#index', defaults: { format: 'json' }
  get '/workflows',      to: 'workflow#index', defaults: { format: 'json' }
  get '/workflows/:id',  to: 'workflow#show',  defaults: { format: 'json' }

  get '/workflows/:workflow_id/subjects' => 'subjects#index'
  get '/workflows/:workflow_id/subject_sets' => 'subject_sets#index'
  get '/subjects/:subject_id', to: 'classifications#show', defaults: { format: 'json'}

  post   '/subjects/:id/favourite', to: 'favourites#create', defaults: { format: 'json'}
  post   '/subjects/:id/unfavourite', to: 'favourites#destroy', defaults: {format:'json'}

  resources :subjects
  resources :subject_sets
  resources :classifications, :defaults => { :format => 'json' }

  get  '/current_user' => "users#logged_in_user"
  resources :favourites, only: [:index, :create, :destroy]
end
