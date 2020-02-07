# == Schema Information
#
# Table name: consumables
#
#  id                       :bigint           not null, primary key
#  title                    :string           not null
#  quantity_in_stock        :integer          default(0), not null
#  quantity_in_use          :integer          default(0), not null
#  quantity_ready_to_refill :integer          default(0), not null
#  quantity_at_refill       :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  consumable_type_id       :bigint           not null
#

class Consumable < ApplicationRecord
  has_and_belongs_to_many :name
  belongs_to :consumable_type

  validates :title,
            :quantity_in_stock,
            :quantity_in_use,
            :quantity_ready_to_refill,
            :quantity_at_refill,
            :consumable_type_id,
    presence: true

  def full_consumable
    "#{consumable_type.title} #{title}"
  end
end
