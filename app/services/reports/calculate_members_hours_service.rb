class Reports::CalculateMembersHoursService
  def initialize(params)
    @params = params
  end

  def perform
    scoped_events
  end

  private

  def members
    @members ||= MembersFinder.new(@params).perform
  end

  def scoped_events
    Event.joins(:members)
         .where(members: { id: members.ids })
         .select(
           'members.id   AS member_id',
           'members.name AS member_name',
           'members.created_at AS member_created_at',
           'COUNT(events.id) AS event_count',
           'SUM(events.duration_seconds) AS total_seconds'
         )
         .group('members.id')
  end
end
