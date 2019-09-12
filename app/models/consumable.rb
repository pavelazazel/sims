# == Schema Information
#
# Table name: consumables
#
#  id                       :bigint           not null, primary key
#  title                    :string           not null
#  name_id                  :bigint           not null
#  quantity_in_stock        :integer          default(0), not null
#  quantity_in_use          :integer          default(0), not null
#  quantity_ready_to_refill :integer          default(0), not null
#  quantity_at_refill       :integer          default(0), not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Consumable < ApplicationRecord
  belongs_to :name

  validates :title,
            :name,
            :quantity_in_stock,
            :quantity_in_use,
            :quantity_ready_to_refill,
            :quantity_at_refill,
    presence: true
end
