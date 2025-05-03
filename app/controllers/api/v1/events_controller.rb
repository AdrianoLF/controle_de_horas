class Api::V1::EventsController < ApplicationController
  before_action :event, only: %i[destroy update show]

  MAX_RESULTS = 10

  def index
    render json: {
      events: events,
      total_pages: events.try(:total_pages) || 1,
      current_page: events.try(:current_page) || 1,
      count_total: events.try(:total_count) || events.count
    }
  end

  def show
    render json: {
      event: @event,
      members: event_members
    }
  end

  def create
    @event = Event.new(permitted_params)
    @event.save ? render_success : render_error
  end

  def destroy
    @event.destroy! and head :ok
  end

  def update
    @event.update(permitted_params)
    @event.save ? render_success : render_error
  end

  private

  def permitted_params
    params.permit(:duration_seconds, :team_id, :title, :description)
  end

  def events
    @events ||= begin
      query = Event.all
      query = query.where("title ILIKE ?", "%#{params[:title]}%") if params[:title].present?
      return query if params[:all_events].present?
      
      query = query.where(team_id: params[:team_id]) if params[:team_id].present?
      query.page(params[:page].presence || 1).per(MAX_RESULTS)
    end
  end

  def event
    @event ||= Event.find(params[:id])
  end

  def event_members
    @event.event_assignments.includes(:member).map do |assignment|
      member = assignment.member
      member.as_json.merge(event_assignment_id: assignment.id)
    end
  end

  def render_success
    render json: { 
      event: @event,
      members: event_members
    }
  end

  def render_error
    render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
  end
end 