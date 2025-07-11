class Api::V1::PublicReportsController < ApplicationController
  skip_before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def hours
    member = Member.find_by!(external_id: params[:ra])

    @member_with_hours = Reports::CalculateMemberHoursService.new(member).perform
    @member_events = member.events.includes(:teams).order(occurred_at: :desc) if @member_with_hours
  end

  private

  def permitted_params
    params.permit(:ra)
  end

  def not_found
    render json: { error: 'Membro não encontrado' }, status: :not_found
  end
end
