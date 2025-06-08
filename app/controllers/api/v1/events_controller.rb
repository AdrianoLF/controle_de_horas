class Api::V1::EventsController < Api::V1::BaseController
  before_action :event, only: %i[destroy update]
  before_action :check_duration, only: %i[create update]

  def index
    scope = EventsFinder.new(permitted_params).perform.includes(:team, :members)
    @events = paginate(scope:, params: permitted_params)
  end

  def show
    event
  end

  def create
    @event = Event.new(permitted_params.except(:member_ids))

    @event.save && manage_members || render_error
  end

  def destroy
    @event.destroy! and head :ok
  end

  def update
    @event.update(permitted_params.except(:member_ids))

    ActiveRecord::Base.transaction do
      if @event.save && manage_members
        head :ok
      else
        render_error
        raise ActiveRecord::Rollback
      end
    end
  end

  private

  def permitted_params
    params.permit(:duration_seconds, :team_id, :title, :description, :page, member_ids: [])
  end

  def event
    @event ||= Event.includes(:team, :members).find(params[:id])
  end

  def render_error
    render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
  end

  def manage_members
    current_member_ids = @event.member_ids
    new_member_ids = Array.wrap(permitted_params[:member_ids]).map(&:to_i)

    @event.event_assignments.where(member_id: current_member_ids - new_member_ids)&.each(&:destroy)
    (new_member_ids - current_member_ids).each { |id| @event.event_assignments.create!(member_id: id) }

    @event.reload
  end

  def check_duration
    return if possible_duration_seconds.include?(permitted_params[:duration_seconds]&.to_i)

    render json: { error: 'Duração inválida' }, status: :unprocessable_entity
  end

  def possible_duration_seconds
    [
      15.minutes.to_i,
      30.minutes.to_i,
      1.hour.to_i,
      2.hours.to_i,
      3.hours.to_i,
      4.hours.to_i
    ]
  end
end
