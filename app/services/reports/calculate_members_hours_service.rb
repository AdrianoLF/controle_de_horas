class Reports::CalculateMembersHoursService
  def initialize(params)
    @params = params
    @member_name = params[:name]
    @page = params[:page]
  end

  def perform
    records = base_scope
    records = calculate_hours_and_events_count(records)
    records = order_by_name(records)
    records
  end

  private

  def base_scope
    MembersFinder.new({name: @member_name, page: @page}).perform
  end

  def calculate_hours_and_events_count(records)
    records
      .left_outer_joins(:events)
      .select(
        'members.id AS member_id',
        'members.name AS member_name',
        'members.created_at AS member_created_at',
        'COALESCE(COUNT(events.id), 0) AS event_count',
        'COALESCE(SUM(events.duration_seconds), 0) AS total_seconds'
      )
      .group('members.id')
  end

  def order_by_name(records)
    records.order('members.name')
  end
end
