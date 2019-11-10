Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'consumable_movements/change_cartridge'
  get 'consumable_movements/get_locations'
  post 'consumable_movements/get_devices'
  post 'consumable_movements/move'
  post 'consumable_movements/abort'

  resources :devices
  resources :names
  resources :types
  resources :brands
  resources :locations
  resources :consumables

  resources :devices_imports, only: [:new, :create]
  resources :consumable_movements, only: [:index, :new, :create, :destroy]
  resources :consumable_types, except: [:show]

  root 'devices#index'
end
