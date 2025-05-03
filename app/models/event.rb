# == Schema Information
#
# Table name: events
#
#  id               :bigint           not null, primary key
#  title            :string
#  description      :text
#  duration_seconds :integer
#  team_id          :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class Event < ApplicationRecord
  belongs_to :team
  has_many :event_assignments, dependent: :destroy
  has_many :members, through: :event_assignments

  validates :duration_seconds, numericality: { greater_than: 0 }
  validates :title, presence: true
  validates :team_id, presence: true
end
