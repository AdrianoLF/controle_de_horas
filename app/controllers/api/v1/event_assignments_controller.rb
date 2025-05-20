class Api::V1::EventAssignmentsController < Api::V1::BaseController
  def create
    @event_assignment = EventAssignment.new(permitted_params)
    
    if @event_assignment.save
      render json: { event_assignment: @event_assignment }
    else
      render json: { errors: @event_assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy_relationship
    @event_assignment = EventAssignment.find_by(member_id: permitted_params[:member_id], event_id: permitted_params[:event_id])
    @event_assignment.destroy!
    head :ok
  end

  private

  def permitted_params
    params.permit(:event_id, :member_id)
  end
end 