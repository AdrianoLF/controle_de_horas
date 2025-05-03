class Api::V1::MembersController < ApplicationController
  before_action :member, only: %i[destroy update]

  MAX_RESULTS = 10

  def index
    @members = Finders::MembersFinder.new(permitted_params).perform.includes(:teams)
  end

  def show
    member
  end

  def create
    @member = Member.new(permitted_params)
    @member.save ? render_success : render_error
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

  def render_success
    render json: { member: @member }
  end

  def render_error
    render json: { errors: @member.errors.full_messages }, status: :unprocessable_entity
  end
end
