class Api::V1::EventsController < Api::V1::BaseController
  before_action :event, only: %i[destroy update]

  def index
    scope = EventsFinder.new(permitted_params).perform.includes(:team, :members)
    @events = paginate(scope:, params: permitted_params)
  end

  def show
    event.includes(:team, :members)
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
    params.permit(:duration_seconds, :team_id, :title, :description, :page)
  end

  def event
    @event ||= Event.find(params[:id])
  end

  def render_error
    render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
  end
end
