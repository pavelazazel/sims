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

  ransack_alias :name, :name_type_title_or_name_brand_title_or_name_model
  ransack_alias :location, :location_department_or_location_room

  self.per_page = 15

  def history_title
    self.name.full_name
  end
end
