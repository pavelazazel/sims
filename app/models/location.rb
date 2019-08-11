# == Schema Information
#
# Table name: locations
#
#  id         :bigint           not null, primary key
#  department :string           not null
#  room       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Location < ApplicationRecord
  has_many :device, dependent: :destroy

  validates :department, :room,
    presence: true

  DEPARTMENTS = %w(
    sikeyrosa
    orbeli
    prosvet
  )

  def full_location
    "#{department} #{room}"
  end
end
