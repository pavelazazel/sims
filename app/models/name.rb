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
  belongs_to :type, optional: true
  belongs_to :brand, optional: true
  has_many :device, dependent: :destroy

  validates :type, :brand, :model,
    presence: true

  def full_name
    "#{type.title} #{brand.title} #{model}"
  end
end
