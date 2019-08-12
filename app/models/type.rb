# == Schema Information
#
# Table name: types
#
#  id         :bigint           not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Type < ApplicationRecord
  has_many :name, dependent: :destroy

  validates :title,
    presence: true
end
