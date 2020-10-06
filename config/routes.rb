Rails.application.routes.draw do
  get 'home/index'
  root to: 'home#index'
  resources :routing_keys do
    get 'verify', on: :collection
    get 'unverify', on: :collection
    get 'delete', on: :collection
    post 'delete', on: :collection, to: 'routing_keys#destroy'
  end
  resources :incoming_message
  # get '/routing_keys/verify', to: 'routing_keys#verify'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
