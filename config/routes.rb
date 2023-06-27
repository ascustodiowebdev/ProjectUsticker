Rails.application.routes.draw do
  resources :stickers
  delete '/stickers/:id', to: 'stickers#destroy', as: 'destroy_sticker'


  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
    # Defines the root path route ("/")
  root "stickers#index"
end
