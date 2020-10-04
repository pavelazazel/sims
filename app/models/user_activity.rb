# == Schema Information
#
# Table name: user_activities
#
#  id          :bigint           not null, primary key
#  user_id     :bigint           not null
#  action      :string           not null
#  object_type :string           not null
#  object_id   :integer          not null
#  info        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class UserActivity < ApplicationRecord
  belongs_to :user
end
