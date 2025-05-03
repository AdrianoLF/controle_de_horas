class Event < ApplicationRecord
  belongs_to :team
  has_many :event_assignments, dependent: :destroy
  has_many :members, through: :event_assignments

  validates :duration_seconds, numericality: { greater_than: 0 }
  validates :title, presence: true
  validates :team_id, presence: true
end
