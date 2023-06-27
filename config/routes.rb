Rails.application.routes.draw do
  resources :stickers do
    member do
      post 'add_to_cart'
      delete 'remove_from_cart'
    end
  end

  delete '/stickers/:id', to: 'stickers#destroy', as: 'destroy_sticker'

  devise_for :users

  root "stickers#index"
  get 'cart', to: 'stickers#view_cart', as: 'cart'
  get 'checkout', to: 'stickers#checkout', as: 'checkout'
  post 'process_order', to: 'stickers#process_order', as: 'process_order'
  get 'order_confirmation/:id', to: 'stickers#order_confirmation', as: 'order_confirmation'
end
