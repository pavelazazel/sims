# == Schema Information
#
# Table name: devices
#
#  id               :bigint           not null, primary key
#  name_id          :bigint           not null
#  inventory_number :string           not null
#  serial_number    :string           not null
#  location_id      :bigint           not null
#  comment          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Device < ApplicationRecord
  belongs_to :name
  belongs_to :location

  validates :name, :inventory_number, :serial_number, :location,
    presence: true
end
