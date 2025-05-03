# == Schema Information
#
# Table name: teams
#
#  id          :bigint           not null, primary key
#  name        :string
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships
  has_many :events, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
