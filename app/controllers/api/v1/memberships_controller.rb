class Api::V1::MembershipsController < ApplicationController
  before_action :set_team

  def create
    member = Member.find(params[:member_id])
    membership = @team.memberships.build(member: member)
    
    if membership.save
      render json: { 
        team: @team,
        members: @team.members
      }
    else
      render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    membership = @team.memberships.find_by!(member_id: params[:id])
    membership.destroy
    
    render json: { 
      team: @team,
      members: @team.members
    }
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end
end 