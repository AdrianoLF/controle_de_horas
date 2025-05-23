class Api::V1::MembersController < Api::V1::BaseController
  before_action :member, only: %i[destroy update]

  def index
    scope = MembersFinder.new(permitted_params).perform.includes(:teams)
    @members = paginate(scope:, params: permitted_params)
  end

  def show
    member.includes(:teams)
  end

  def create
    @member = Member.new(permitted_params)
    @member.save || render_error
  end

  def destroy
    @member.destroy! and head :ok
  end

  def update
    @member.update(permitted_params)
    @member.save ? render_success : render_error
  end

  private

  def permitted_params
    params.permit(:name, :all_records, :page)
  end

  def member
    @member ||= Member.find(params[:id])
  end

  def render_error
    render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
  end
end
