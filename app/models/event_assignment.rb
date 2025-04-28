class EventAssignment < ApplicationRecord
  belongs_to :event
  belongs_to :member

  validate :member_is_in_team

  private

  def member_is_in_team
    errors.add(:member, "não faz parte desta team") unless
      member.teams.exists?(event.team_id)
  end
end