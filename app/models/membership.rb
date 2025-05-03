# == Schema Information
#
# Table name: memberships
#
#  id         :bigint           not null, primary key
#  team_id    :bigint           not null
#  member_id  :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Membership < ApplicationRecord
  belongs_to :team
  belongs_to :member
end
