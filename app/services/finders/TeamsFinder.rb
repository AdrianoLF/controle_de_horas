class Finders::TeamsFinder
  MAX_RESULTS = 10

  def initialize(params)
    @params = params
  end

  def perform
    teams = base_scope
    teams = filter_by_name(teams)
    teams = with_member_count(teams)
    teams = paginate(teams) unless show_all_records?
    teams
  end

  private

  def base_scope
    Team.all
  end

  def filter_by_name(scope)
    return scope unless @params[:name].present?

    scope.where('teams.name ILIKE ?', "%#{@params[:name]}%")
  end

  def with_member_count(scope)
    scope
    .left_joins(:memberships).distinct
    .select('teams.*, COUNT(memberships.id) AS member_count')
         .group('teams.id')
  end

  def paginate(scope)
    scope.page(@params[:page] || 1).per(MAX_RESULTS)
  end

  def show_all_records?
    @params[:all_records].present?
  end
end
