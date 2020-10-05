Rails.application.routes.draw do
  resources :routing_keys do
    get 'verify', on: :collection
  end
  resources :incoming_message
  # get '/routing_keys/verify', to: 'routing_keys#verify'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
