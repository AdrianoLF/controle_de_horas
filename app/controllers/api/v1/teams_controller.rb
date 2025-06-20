class Api::V1::TeamsController < Api::V1::BaseController
  before_action :team, only: %i[destroy update]

  def index
    scope = TeamsFinder.new(permitted_params).perform
    @teams = paginate(scope:, params: permitted_params)
  end

  def show
    team
  end

  def create
    @team = Team.new(permitted_params)
    @team.save || render_error
  end

  def destroy
    @team.destroy! and head :ok
  end

  def update
    @team.update(permitted_params)
    @team.save || render_error
  end

  private

  def permitted_params
    params.permit(:name, :all_records, :page, :sort_by, :sort_order)
  end

  def team
    @team ||= Team.find(params[:id])
  end

  def render_error
    render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
  end
end
