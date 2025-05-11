class Api::V1::EventAssignmentsController < Api::V1::BaseController
  def create
    @event_assignment = EventAssignment.new(permitted_params)
    
    if @event_assignment.save
      render json: { event_assignment: @event_assignment }
    else
      render json: { errors: @event_assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @event_assignment = EventAssignment.find(params[:id])
    @event_assignment.destroy!
    head :ok
  end

  private

  def permitted_params
    params.permit(:event_id, :member_id)
  end
end 