class Api::V1::SuperAdmin::ReportsController < Api::V1::SuperAdmin::BaseController
  def hours
    scope = Reports::CalculateMembersHoursService.new(params).perform
    @members_with_hours = paginate(scope:, params: permitted_params)
  end

  private

  def permitted_params
    params.permit(:name, :all_records, :page)
  end
end