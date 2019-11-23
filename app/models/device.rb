# == Schema Information
#
# Table name: devices
#
#  id               :bigint           not null, primary key
#  name_id          :bigint           not null
#  inventory_number :string           not null
#  serial_number    :string           not null
#  location_id      :bigint           not null
#  comment          :text             default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Device < ApplicationRecord
  belongs_to :name, optional: true
  belongs_to :location, optional: true

  validates :name, :inventory_number, :serial_number, :location,
    presence: true

  ransack_alias :all_devices,
                :id_or_name_type_title_or_name_brand_title_or_name_model_or_inventory_number_or_serial_number_or_location_department_or_location_room_or_comment
end
