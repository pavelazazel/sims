# == Schema Information
#
# Table name: brands
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Brand < ApplicationRecord
  has_many :name, dependent: :destroy

  validates :title,
    presence: true
end
