class Api::V1::MembersController < ApplicationController
  before_action :member, only: %i[destroy update show]

  MAX_RESULTS = 10

  def index
    render json: {
      members: members,
      total_pages: members.try(:total_pages) || 1,
      current_page: members.try(:current_page) || 1,
      count_total: members.try(:total_count) || members.count
    }
  end

  def show
    render json: {
      member: @member
    }
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
    params.permit(:name)
  end

  def members
    @members ||= begin
      query = Member.where("name ILIKE ?", "%#{params[:name]}%")
      return query if params[:all_members].present?
      
      query.page(params[:page].presence || 1).per(MAX_RESULTS)
    end
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
