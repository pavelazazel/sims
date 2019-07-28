# == Schema Information
#
# Table name: names
#
#  id         :bigint           not null, primary key
#  type_id    :bigint           not null
#  brand_id   :bigint           not null
#  model      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Name < ApplicationRecord
  belongs_to :type
  belongs_to :brand
  has_many :device, dependent: :destroy

  validates :type, :brand, :model,
    presence: true
end
