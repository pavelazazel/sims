Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get  'devices/get_departments'
  get  'devices/get_locations'
  get  'consumable_movements/change_cartridge'
  get  'consumable_movements/get_locations'
  post 'devices/move'
  post 'consumable_movements/get_devices'
  post 'consumable_movements/move'
  post 'consumable_movements/abort'

  resources :devices
  resources :names
  resources :types, except: [:show]
  resources :brands, except: [:show]
  resources :locations, except: [:show]
  resources :consumables

  resources :devices_imports, only: [:new, :create]
  resources :consumable_movements, only: [:index, :new, :create, :destroy]
  resources :consumable_types, except: [:show]

  root 'devices#index'
end
