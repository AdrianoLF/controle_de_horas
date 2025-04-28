class EventAssignment < ApplicationRecord
  belongs_to :event
  belongs_to :member

  validate :member_is_in_planilha

  private

  def member_is_in_planilha
    errors.add(:member, "não faz parte desta planilha") unless
      member.planilhas.exists?(event.planilha_id)
  end
end