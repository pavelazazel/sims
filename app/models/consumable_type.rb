# == Schema Information
#
# Table name: consumable_types
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ConsumableType < ApplicationRecord
  has_many :consumable, dependent: :destroy

  validates :title,
    presence: true
end
