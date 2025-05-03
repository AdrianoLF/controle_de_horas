class Api::V1::EventsController < ApplicationController
  before_action :event, only: %i[destroy update]

  MAX_RESULTS = 10

  def index
    @events = EventsFinder.new(permitted_params).perform.includes(:members, :team)
  end

  def show
    event
  end

  def create
    @event = Event.new(permitted_params)
    @event.save || render_error
  end

  def destroy
    @event.destroy! and head :ok
  end

  def update
    @event.update(permitted_params)
    @event.save || render_error
  end

  private

  def permitted_params
    params.permit(:duration_seconds, :team_id, :title, :description)
  end

  def event
    @event ||= Event.find(params[:id])
  end

  def render_error
    render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
  end
end 