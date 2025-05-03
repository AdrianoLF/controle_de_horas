class TeamsFinder
  MAX_RESULTS = 10

  def initialize(params)
    @params = params
  end

  def perform
    teams = base_scope
    teams = filter_by_name(teams)
    teams = with_member_count(teams)
    teams = paginate(teams)
    teams
  end

  private

  def base_scope
    Team.all
  end

  def filter_by_name(scope)
    return scope if @params[:name].blank?

    scope.where('teams.name ILIKE ?', "%#{@params[:name]}%")
  end

  def with_member_count(scope)
    scope
    .left_joins(:memberships).distinct
    .select('teams.*, COUNT(memberships.id) AS member_count')
         .group('teams.id')
  end

  def paginate(scope)
    max_results = show_all_records? ? 999_999 : MAX_RESULTS
    scope.page(@params[:page] || 1).per(max_results)
  end

  def show_all_records?
    @params[:all_records].present?
  end
end
