class Api::V1::MembersController < Api::V1::BaseController
  before_action :member, only: %i[update show]

  def index
    scope = MembersFinder.new(permitted_params).perform.includes(:teams)
    @members = paginate(scope:, params: permitted_params)
  end

  def show
    @member
  end

  def create
    @member = Member.new(permitted_params)
    @member.save || render_error
  end

  def update
    @member.update(permitted_params) || render_error
  end

  private

  def permitted_params
    params.permit(:name, :pix_key, :all_records, :page, :active, :sort_by, :sort_order, team_ids: [])
  end

  def member
    @member ||= Member.includes(:memberships, :teams).find(params[:id])
  end

  def render_error
    render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
  end
end
