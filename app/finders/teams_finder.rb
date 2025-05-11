class TeamsFinder
  def initialize(params)
    @params = params
  end

  def perform
    teams = base_scope
    teams = filter_by_name(teams)
    teams = with_member_count(teams)
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
end
