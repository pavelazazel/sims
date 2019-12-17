# == Schema Information
#
# Table name: consumable_movements
#
#  id            :bigint           not null, primary key
#  consumable_id :bigint           not null
#  location_id   :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ConsumableMovement < ApplicationRecord
  belongs_to :consumable
  belongs_to :location

  validates :consumable, :location,
    presence: true

  self.per_page = 15
end
