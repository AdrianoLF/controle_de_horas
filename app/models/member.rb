# == Schema Information
#
# Table name: members
#
#  id         :bigint           not null, primary key
#  name       :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  active     :boolean          default(TRUE)
#  pix_key    :string
#
class Member < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships
  has_many :event_assignments, dependent: :destroy
  has_many :events, through: :event_assignments

  validates :name, presence: true
  validates :pix_key, uniqueness: true
end
