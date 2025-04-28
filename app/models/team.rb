class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships
  has_many :events, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end