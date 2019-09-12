Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'devices/index'

  resources :devices
  resources :names
  resources :types
  resources :brands
  resources :locations
  resources :consumables

  resources :devices_imports, only: [:new, :create]

  root 'devices#index'
end
