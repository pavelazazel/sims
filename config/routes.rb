Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users', sessions: 'users/sessions' }

  get  'devices/get_departments'
  get  'devices/get_locations'
  get  'consumables/get_types'
  get  'consumable_movements/get_locations'
  get  'consumable_movements/change_cartridge'
  get  'user_activities/filter'
  post 'devices/move'
  post 'devices/is_swappable'
  post 'consumables/get_consumables'
  post 'consumables/refill'
  post 'consumable_movements/get_devices'
  post 'consumable_movements/move'
  post 'consumable_movements/abort'

  resources :devices, except: [:show]
  resources :names
  resources :types, except: [:show]
  resources :brands, except: [:show]
  resources :locations, except: [:show]
  resources :users, except: [:show]
  resources :consumables
  resources :devices_imports, only: [:new, :create]
  resources :consumable_movements, only: [:index, :new, :create, :destroy]
  resources :consumable_types, except: [:show]
  resources :user_activities, only: [:index]

  root 'devices#index'
end
