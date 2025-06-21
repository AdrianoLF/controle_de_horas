class EventsFinder
  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def perform
    scope = Event.left_joins(:team).includes(:team, :members)
    scope = filter_by_team(scope)
    scope = filter_by_search(scope)
    scope = filter_by_occurred_range(scope)
    sort(scope)
  end

  private

  def filter_by_team(scope)
    return scope if params[:team_ids].blank?

    scope.where(team_id: params[:team_ids])
  end

  def filter_by_search(scope)
    return scope if params[:search].blank?

    scope.where('events.title ILIKE ?', "%#{params[:search]}%")
  end

  def sort(scope)
    sort_by = params[:sort_by]
    sort_order = params[:sort_order] || 'desc'

    order_clause = case sort_by
                   when 'title', 'duration_seconds', 'occurred_at'
                     "events.#{sort_by} #{sort_order}"
                   when 'team_name'
                     "teams.name #{sort_order}"
                   when 'members_count'
                     count = 'SELECT COUNT(*) FROM event_assignments WHERE event_assignments.event_id = events.id'
                     "(#{count}) #{sort_order}"
                   else
                     'events.occurred_at desc'
                   end

    scope.order(Arel.sql(order_clause))
  end

  def filter_by_occurred_range(scope)
    return scope if params[:occurred_from].blank? && params[:occurred_to].blank?

    from = params[:occurred_from].present? ? Date.parse(params[:occurred_from]) : nil
    to = params[:occurred_to].present? ? Date.parse(params[:occurred_to]) : nil
    build_date_range_query(scope, from, to)

    if from && to
      scope.where(occurred_at: from.beginning_of_day..to.end_of_day)
    elsif from
      scope.where('events.occurred_at >= ?', from.beginning_of_day)
    else
      scope.where('events.occurred_at <= ?', to.end_of_day)
    end
  end
end
