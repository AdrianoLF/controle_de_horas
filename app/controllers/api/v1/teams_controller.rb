class Api::V1::TeamsController < ApplicationController
  before_action :team, only: %i[destroy update show]

  MAX_RESULTS = 10

  def index
    if params[:all_teams].present?
      render json: {
        teams: teams,
        total_pages: 1,
        current_page: 1,
        count_total: teams.count
      }
    else
      render json: {
        teams: teams_with_counts,
        total_pages: teams.total_pages,
        current_page: teams.current_page,
        count_total: teams.total_count
      }
    end
  end

  def show
    render json: {
      team: @team,
      members: @team.members
    }
  end

  def create
    @team = Team.new(permitted_params)
    @team.save ? render_success : render_error
  end

  def destroy
    @team.destroy! and head :ok
  end

  def update
    @team.update(permitted_params)
    @team.save ? render_success : render_error
  end

  private

  def permitted_params
    params.permit(:name)
  end

  def teams
    @teams ||= begin
      query = Team.where("name ILIKE ?", "%#{params[:name]}%")
      return query if params[:all_teams].present?
      
      query.page(params[:page].presence || 1).per(MAX_RESULTS)
    end
  end

  def teams_with_counts
    team_ids = teams.pluck(:id)
    
    counts = Membership.where(team_id: team_ids)
              .group(:team_id)
              .count
    
    teams.map do |team|
      team.as_json.merge(member_count: counts[team.id] || 0)
    end
  end

  def team
    @team ||= Team.find(params[:id])
  end

  def render_success
    render json: { team: @team }
  end

  def render_error
    render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
  end
end 