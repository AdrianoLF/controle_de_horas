class Member < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :planilhas, through: :memberships
  has_many :event_assignments, dependent: :destroy
  has_many :events, through: :event_assignments

  validates :name, presence: true, uniqueness: true
end