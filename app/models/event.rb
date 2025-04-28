
class Event < ApplicationRecord
  belongs_to :planilha
  has_many :event_assignments, dependent: :destroy
  has_many :members, through: :event_assignments

  validates :duration_seconds, numericality: { greater_than: 0 }
end
